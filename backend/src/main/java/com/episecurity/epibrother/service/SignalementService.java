package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.response.SignalementResponse;
import com.episecurity.epibrother.model.entity.Signalement;
import com.episecurity.epibrother.repository.SignalementRepository;
import com.episecurity.epibrother.repository.UserRepository;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;
import java.util.Set;

@Service
public class SignalementService {

    private final SignalementRepository signalementRepository;
    private final UserRepository userRepository;
    private static final Set<String> VALID_STATUSES =
            Set.of("PENDING", "REVIEWED", "DISMISSED", "RESOLVED");

    public SignalementService(SignalementRepository signalementRepository,
                              UserRepository userRepository) {
        this.signalementRepository = signalementRepository;
        this.userRepository = userRepository;
    }

    public List<SignalementResponse> getAllSignalements(String status) {
        List<Signalement> list;
        if (status != null && !status.isBlank()) {
            list = signalementRepository.findByStatusOrderByCreatedAtDesc(status.toUpperCase());
        } else {
            list = signalementRepository.findAllByOrderByCreatedAtDesc();
        }
        return list.stream()
                .map(SignalementResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public List<SignalementResponse> getAllSignalements(String status, String username) {
        if (username == null || username.isBlank()) {
            return getAllSignalements(status);
        }

        User current = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Utilisateur introuvable"));

        if (current.getRole() == RoleType.ADMIN) {
            return getAllSignalements(status);
        }

        List<Signalement> list;
        if (status != null && !status.isBlank()) {
            list = signalementRepository.findByStatusOrderByCreatedAtDesc(status.toUpperCase());
        } else {
            list = signalementRepository.findAllByOrderByCreatedAtDesc();
        }

        return list.stream()
                .filter(signalement -> signalement.getMessage() != null
                        && signalement.getMessage().getSender() != null
                        && signalement.getMessage().getSender().getManager() != null
                        && signalement.getMessage().getSender().getManager().getId().equals(current.getId()))
                .map(SignalementResponse::fromEntity)
                .collect(Collectors.toList());
    }

    public SignalementResponse getSignalementById(Long id) {
        Signalement signalement = signalementRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Signalement introuvable avec l'id: " + id));
        return SignalementResponse.fromEntity(signalement);
    }

    public SignalementResponse updateStatus(Long id, String newStatus) {
        if (newStatus == null || !VALID_STATUSES.contains(newStatus.toUpperCase())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Statut de signalement invalide.");
        }
        Signalement signalement = signalementRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Signalement introuvable avec l'id: " + id));

        signalement.setStatus(newStatus.toUpperCase());
        Signalement updated = signalementRepository.save(signalement);
        return SignalementResponse.fromEntity(updated);
    }
}
