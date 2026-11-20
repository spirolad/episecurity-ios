package com.episecurity.epibrother.controller;

import com.episecurity.epibrother.dto.request.SendMessageRequest;
import com.episecurity.epibrother.dto.response.MessageResponse;
import com.episecurity.epibrother.service.MessageService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/messages")
@CrossOrigin(origins = "*")
public class MessageController {

    private final MessageService messageService;

    public MessageController(MessageService messageService) {
        this.messageService = messageService;
    }

    /**
     * Endpoint pour envoyer un message.
     * Accessible par ADMIN, MANAGER, et EMPLOYEE (qui doit cibler une personne).
     */
    @PostMapping
    public ResponseEntity<MessageResponse> sendMessage(
            @Valid @RequestBody SendMessageRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        String currentUsername = userDetails != null ? userDetails.getUsername() : null;
        MessageResponse response = messageService.sendMessage(request, currentUsername);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Liste les messages :
     * - Pour un EMPLOYEE ou MANAGER : uniquement les messages dont il est la cible.
     * - Pour un ADMIN : tous les messages.
     */
    @GetMapping
    public ResponseEntity<List<MessageResponse>> getAllMessages(
            @AuthenticationPrincipal UserDetails userDetails) {
        String currentUsername = userDetails != null ? userDetails.getUsername() : null;
        return ResponseEntity.ok(messageService.getAuthorizedMessages(currentUsername));
    }

    /**
     * Détail d'un message :
     * - Pour un EMPLOYEE ou MANAGER : interdit (403) s'il n'est pas le destinataire cible.
     * - Pour un ADMIN : autorisé.
     */
    @GetMapping("/{id}")
    public ResponseEntity<MessageResponse> getMessageById(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        String currentUsername = userDetails != null ? userDetails.getUsername() : null;
        return ResponseEntity.ok(messageService.getAuthorizedMessageById(id, currentUsername));
    }
}
