package com.episecurity.epibrother.service;

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
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class MessageServiceTest {

    private MessageRepository messageRepository;
    private UserRepository userRepository;
    private SignalementRepository signalementRepository;
    private AiAnalysisService aiAnalysisService;
    private MessageService messageService;

    @BeforeEach
    void setUp() {
        messageRepository = mock(MessageRepository.class);
        userRepository = mock(UserRepository.class);
        signalementRepository = mock(SignalementRepository.class);
        aiAnalysisService = new AiAnalysisService();

        messageService = new MessageService(
                messageRepository,
                userRepository,
                signalementRepository,
                aiAnalysisService
        );
    }

    @Test
    void testSendMessage_WithoutKeyword_ShouldNotCreateSignalement() {
        User sender = new User("alice", RoleType.EMPLOYEE, "Alice Martin");
        sender.setId(1L);

        User recipient = new User("bob", RoleType.EMPLOYEE, "Bob Durand");
        recipient.setId(2L);
        User manager = new User("manager", RoleType.MANAGER, "Manager");
        manager.setId(3L);
        sender.setManager(manager);
        recipient.setManager(manager);

        when(userRepository.findById(1L)).thenReturn(Optional.of(sender));
        when(userRepository.findById(2L)).thenReturn(Optional.of(recipient));
        when(messageRepository.save(any(Message.class))).thenAnswer(invocation -> {
            Message m = invocation.getArgument(0);
            m.setId(10L);
            return m;
        });

        SendMessageRequest request = new SendMessageRequest(1L, 2L, "Salut Bob, comment se passe ton projet ?");
        MessageResponse response = messageService.sendMessage(request);

        assertNotNull(response);
        assertEquals(10L, response.getId());
        assertFalse(response.isFlaggedByAi());
        verify(signalementRepository, never()).save(any(Signalement.class));
    }

    @Test
    void testSendMessage_WithEpitaKeyword_ShouldCreateSignalement() {
        User sender = new User("alice", RoleType.EMPLOYEE, "Alice Martin");
        sender.setId(1L);

        User recipient = new User("bob", RoleType.EMPLOYEE, "Bob Durand");
        recipient.setId(2L);
        User manager = new User("manager", RoleType.MANAGER, "Manager");
        manager.setId(3L);
        sender.setManager(manager);
        recipient.setManager(manager);

        when(userRepository.findById(1L)).thenReturn(Optional.of(sender));
        when(userRepository.findById(2L)).thenReturn(Optional.of(recipient));
        when(messageRepository.save(any(Message.class))).thenAnswer(invocation -> {
            Message m = invocation.getArgument(0);
            m.setId(11L);
            return m;
        });
        when(signalementRepository.save(any(Signalement.class))).thenAnswer(invocation -> {
            Signalement s = invocation.getArgument(0);
            s.setId(100L);
            return s;
        });

        SendMessageRequest request = new SendMessageRequest(1L, 2L, "Retrouvons-nous demain matin devant l'école Epita.");
        MessageResponse response = messageService.sendMessage(request);

        assertNotNull(response);
        assertEquals(11L, response.getId());
        assertTrue(response.isFlaggedByAi());

        ArgumentCaptor<Signalement> captor = ArgumentCaptor.forClass(Signalement.class);
        verify(signalementRepository, times(1)).save(captor.capture());

        Signalement captured = captor.getValue();
        assertEquals("HIGH", captured.getSeverity());
        assertEquals("PENDING", captured.getStatus());
        assertTrue(captured.getReason().contains("Epita"));
        assertEquals(11L, captured.getMessage().getId());
    }

    @Test
    void testSendEncryptedMessage_UsesFrontendAnalysis() {
        User sender = new User("alice", RoleType.EMPLOYEE, "Alice Martin");
        sender.setId(1L);
        User recipient = new User("bob", RoleType.EMPLOYEE, "Bob Durand");
        recipient.setId(2L);
        User manager = new User("manager", RoleType.MANAGER, "Manager");
        manager.setId(3L);
        sender.setManager(manager);
        recipient.setManager(manager);

        when(userRepository.findById(1L)).thenReturn(Optional.of(sender));
        when(userRepository.findById(2L)).thenReturn(Optional.of(recipient));
        when(messageRepository.save(any(Message.class))).thenAnswer(invocation -> {
            Message message = invocation.getArgument(0);
            message.setId(12L);
            return message;
        });
        when(signalementRepository.save(any(Signalement.class))).thenAnswer(invocation -> {
            Signalement signalement = invocation.getArgument(0);
            signalement.setId(101L);
            return signalement;
        });

        SendMessageRequest request = new SendMessageRequest(
                1L,
                2L,
                "ENC:Y2lwaGVydGV4dA==",
                true,
                "Analyse IA (DLP) : mot sensible détecté",
                "HIGH");

        MessageResponse response = messageService.sendMessage(request);

        assertTrue(response.isFlaggedByAi());
        ArgumentCaptor<Signalement> captor = ArgumentCaptor.forClass(Signalement.class);
        verify(signalementRepository, times(1)).save(captor.capture());
        assertEquals("HIGH", captor.getValue().getSeverity());
        assertTrue(captor.getValue().getReason().contains("DLP"));
    }
}
