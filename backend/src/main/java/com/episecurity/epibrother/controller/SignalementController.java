package com.episecurity.epibrother.controller;

import com.episecurity.epibrother.dto.request.UpdateSignalementRequest;
import com.episecurity.epibrother.dto.response.SignalementResponse;
import com.episecurity.epibrother.service.SignalementService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/signalements")
@PreAuthorize("hasAnyRole('ADMIN', 'MANAGER')")
@CrossOrigin(origins = "*")
public class SignalementController {

    private final SignalementService signalementService;

    public SignalementController(SignalementService signalementService) {
        this.signalementService = signalementService;
    }

    /**
     * Endpoint consulté par les Managers / Admins pour voir les remontées générées par l'IA.
     */
    @GetMapping
    public ResponseEntity<List<SignalementResponse>> getAllSignalements(
            @RequestParam(required = false) String status,
            @AuthenticationPrincipal UserDetails userDetails) {
        String username = userDetails != null ? userDetails.getUsername() : null;
        return ResponseEntity.ok(signalementService.getAllSignalements(status, username));
    }

    @GetMapping("/{id}")
    public ResponseEntity<SignalementResponse> getSignalementById(@PathVariable Long id) {
        return ResponseEntity.ok(signalementService.getSignalementById(id));
    }

    /**
     * Permet à un manager ou admin de marquer un signalement comme traité (ex: REVIEWED, DISMISSED).
     */
    @PatchMapping("/{id}")
    public ResponseEntity<SignalementResponse> updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateSignalementRequest request) {
        return ResponseEntity.ok(signalementService.updateStatus(id, request.getStatus()));
    }
}
