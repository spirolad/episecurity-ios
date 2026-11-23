package com.episecurity.epibrother.service;

import com.episecurity.epibrother.dto.response.SignalementResponse;
import com.episecurity.epibrother.model.entity.Signalement;
import com.episecurity.epibrother.repository.SignalementRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class SignalementService {

    private final SignalementRepository signalementRepository;

    public SignalementService(SignalementRepository signalementRepository) {
        this.signalementRepository = signalementRepository;
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

    public SignalementResponse getSignalementById(Long id) {
        Signalement signalement = signalementRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Signalement introuvable avec l'id: " + id));
        return SignalementResponse.fromEntity(signalement);
    }

    public SignalementResponse updateStatus(Long id, String newStatus) {
        Signalement signalement = signalementRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Signalement introuvable avec l'id: " + id));

        signalement.setStatus(newStatus.toUpperCase());
        Signalement updated = signalementRepository.save(signalement);
        return SignalementResponse.fromEntity(updated);
    }
}
