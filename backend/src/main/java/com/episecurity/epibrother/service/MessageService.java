package com.episecurity.epibrother.service;

import com.episecurity.epibrother.ai.AiAnalysisResult;
import com.episecurity.epibrother.ai.AiAnalysisService;
import com.episecurity.epibrother.dto.request.SendMessageRequest;
import com.episecurity.epibrother.dto.response.MessageResponse;
import com.episecurity.epibrother.model.entity.Message;
import com.episecurity.epibrother.model.entity.Signalement;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.MessageRepository;
import com.episecurity.epibrother.repository.SignalementRepository;
import com.episecurity.epibrother.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class MessageService {

    private static final Logger log = LoggerFactory.getLogger(MessageService.class);

    private final MessageRepository messageRepository;
    private final UserRepository userRepository;
    private final SignalementRepository signalementRepository;
    private final AiAnalysisService aiAnalysisService;

    public MessageService(MessageRepository messageRepository,
                          UserRepository userRepository,
                          SignalementRepository signalementRepository,
                          AiAnalysisService aiAnalysisService) {
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
        this.signalementRepository = signalementRepository;
        this.aiAnalysisService = aiAnalysisService;
    }

    @Transactional
    public MessageResponse sendMessage(SendMessageRequest request, String currentUsername) {
        User sender;

        if (currentUsername != null && !currentUsername.isBlank()) {
            User currentUser = userRepository.findByUsername(currentUsername)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur courant introuvable: " + currentUsername));

            // Si l'utilisateur n'est pas ADMIN et qu'un senderId différent a été spécifié -> refus
            if (request.getSenderId() != null && !request.getSenderId().equals(currentUser.getId()) && currentUser.getRole() != RoleType.ADMIN) {
                throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Interdiction d'usurper l'identité d'un autre utilisateur.");
            }

            // Pour un employé, il doit obligatoirement envoyer le message à une personne (destinataire obligatoire)
            if (currentUser.getRole() == RoleType.EMPLOYEE && request.getRecipientId() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Un employé doit obligatoirement spécifier un destinataire.");
            }

            sender = (request.getSenderId() != null && currentUser.getRole() == RoleType.ADMIN)
                    ? userRepository.findById(request.getSenderId()).orElse(currentUser)
                    : currentUser;
        } else {
            // Cas sans utilisateur authentifié explicite (fallback/tests)
            if (request.getSenderId() == null) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "senderId obligatoire");
            }
            sender = userRepository.findById(request.getSenderId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Expéditeur introuvable avec l'id: " + request.getSenderId()));
        }

        User recipient = null;
        if (request.getRecipientId() != null) {
            recipient = userRepository.findById(request.getRecipientId())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Destinataire introuvable avec l'id: " + request.getRecipientId()));
        }

        boolean employeeCanContactRecipient = recipient != null
                && (recipient.getRole() == RoleType.ADMIN
                || (recipient.getRole() == RoleType.MANAGER
                && sender.getManager() != null
                && recipient.getId().equals(sender.getManager().getId()))
                || (recipient.getRole() == RoleType.EMPLOYEE
                && recipient.getManager() != null
                && sender.getManager() != null
                && recipient.getManager().getId().equals(sender.getManager().getId())));
        if (sender.getRole() == RoleType.EMPLOYEE && !employeeCanContactRecipient) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "Vous ne pouvez envoyer un message qu'à un collègue de votre équipe, à votre manager ou à un administrateur.");
        }

        // 1. Sauvegarde du message
        Message message = new Message(sender, recipient, request.getContent());
        Message savedMessage = messageRepository.save(message);
        log.info("Message id={} enregistré avec succès (expéditeur: {})", savedMessage.getId(), sender.getUsername());

        // Le texte peut être chiffré côté client. Le frontend fournit donc le résultat
        // de l'analyse effectuée avant chiffrement.
        AiAnalysisResult analysisResult = request.isFlaggedByAi()
                ? AiAnalysisResult.flagged(
                        request.getAnalysisReason(),
                        request.getAnalysisSeverity(),
                        0.95)
                : aiAnalysisService.analyze(savedMessage.getContent());

        boolean flagged = analysisResult.isFlagged();
        if (flagged) {
            String reason = request.isFlaggedByAi()
                    ? request.getAnalysisReason()
                    : analysisResult.getReason();
            if (reason == null || reason.isBlank()) {
                reason = "Analyse IA côté client : comportement potentiellement problématique détecté";
            }

            String severity = request.isFlaggedByAi()
                    ? request.getAnalysisSeverity()
                    : analysisResult.getSeverity();
            if (!"HIGH".equalsIgnoreCase(severity) && !"MEDIUM".equalsIgnoreCase(severity)
                    && !"LOW".equalsIgnoreCase(severity)) {
                severity = "HIGH";
            } else {
                severity = severity.toUpperCase();
            }

            Signalement signalement = new Signalement(
                    savedMessage,
                    reason,
                    severity,
                    "PENDING"
            );
            Signalement savedSignalement = signalementRepository.save(signalement);
            Long signalementId = savedSignalement != null ? savedSignalement.getId() : null;
            log.warn("🚨 SIGNALEMENT créé avec succès (id={}) pour le message id={} !",
                    signalementId, savedMessage.getId());
        }

        return MessageResponse.fromEntity(savedMessage, flagged);
    }

    public MessageResponse sendMessage(SendMessageRequest request) {
        return sendMessage(request, null);
    }

    /**
     * Récupère les messages autorisés :
     * - Si EMPLOYEE ou MANAGER : UNIQUEMENT les messages dont l'utilisateur est la cible (destinataire)
     * - Si ADMIN : tous les messages
     */
    @Transactional(readOnly = true)
    public List<MessageResponse> getAuthorizedMessages(String currentUsername) {
        if (currentUsername == null || currentUsername.isBlank()) {
            return getAllMessages();
        }

        User currentUser = userRepository.findByUsername(currentUsername)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable: " + currentUsername));

        // Les employés et les managers peuvent lire uniquement leurs conversations,
        // dans les deux sens (envoyé ou reçu).
        if (currentUser.getRole() != RoleType.ADMIN) {
            List<Message> sent = messageRepository.findBySenderIdOrderByCreatedAtDesc(currentUser.getId());
            List<Message> received = messageRepository.findByRecipientIdOrderByCreatedAtDesc(currentUser.getId());
            java.util.LinkedHashMap<Long, Message> conversations = new java.util.LinkedHashMap<>();
            sent.forEach(msg -> conversations.putIfAbsent(msg.getId(), msg));
            received.forEach(msg -> conversations.putIfAbsent(msg.getId(), msg));
            return conversations.values().stream()
                    .map(msg -> MessageResponse.fromEntity(msg, false))
                    .collect(Collectors.toList());
        }

        return getAllMessages();
    }

    @Transactional(readOnly = true)
    public List<MessageResponse> getAllMessages() {
        return messageRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(msg -> MessageResponse.fromEntity(msg, false))
                .collect(Collectors.toList());
    }

    /**
     * Récupère un message par son ID :
     * - Si EMPLOYEE ou MANAGER : vérifie qu'il est bien la cible (destinataire) du message, sinon 403 FORBIDDEN
     * - Si ADMIN : accès accordé à tous les messages
     */
    @Transactional(readOnly = true)
    public MessageResponse getAuthorizedMessageById(Long id, String currentUsername) {
        Message message = messageRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Message introuvable avec l'id: " + id));

        if (currentUsername != null && !currentUsername.isBlank()) {
            User currentUser = userRepository.findByUsername(currentUsername)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable: " + currentUsername));

            if (currentUser.getRole() != RoleType.ADMIN) {
                boolean isParticipant = message.getSender().getId().equals(currentUser.getId())
                        || (message.getRecipient() != null
                        && message.getRecipient().getId().equals(currentUser.getId()));
                if (!isParticipant) {
                    throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                            "Accès refusé : vous ne pouvez lire que vos conversations.");
                }
            }
        }

        return MessageResponse.fromEntity(message, false);
    }

    public MessageResponse getMessageById(Long id) {
        return getAuthorizedMessageById(id, null);
    }
}
