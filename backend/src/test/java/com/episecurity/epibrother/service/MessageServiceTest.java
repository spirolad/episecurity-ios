package com.episecurity.epibrother.service;

import com.episecurity.epibrother.ai.AiAnalysisService;
import com.episecurity.epibrother.ai.AiAnalysisResult;
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
        aiAnalysisService = mock(AiAnalysisService.class);
        when(aiAnalysisService.analyze(anyString())).thenReturn(AiAnalysisResult.clean());

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
    void testSendMessage_UsesServerAnalysisResultToCreateSignalement() {
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

        when(aiAnalysisService.analyze("You are worthless and should leave this team."))
                .thenReturn(AiAnalysisResult.flagged("AI moderation (harassment): Targeted abuse", "HIGH", 0.91));
        SendMessageRequest request = new SendMessageRequest(1L, 2L, "You are worthless and should leave this team.");
        MessageResponse response = messageService.sendMessage(request);

        assertNotNull(response);
        assertEquals(11L, response.getId());
        assertTrue(response.isFlaggedByAi());

        ArgumentCaptor<Signalement> captor = ArgumentCaptor.forClass(Signalement.class);
        verify(signalementRepository, times(1)).save(captor.capture());

        Signalement captured = captor.getValue();
        assertEquals("HIGH", captured.getSeverity());
        assertEquals("PENDING", captured.getStatus());
        assertTrue(captured.getReason().contains("harassment"));
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
                "ENC:Y2lwaGVydGV4dA==");
        request.setAnalysisContent("actual workplace threat");
        when(aiAnalysisService.analyze("actual workplace threat"))
                .thenReturn(AiAnalysisResult.flagged("AI moderation (threat_or_violence): Threat detected", "HIGH", 0.93));

        MessageResponse response = messageService.sendMessage(request);

        assertTrue(response.isFlaggedByAi());
        ArgumentCaptor<Signalement> captor = ArgumentCaptor.forClass(Signalement.class);
        verify(signalementRepository, times(1)).save(captor.capture());
        assertEquals("HIGH", captor.getValue().getSeverity());
        assertTrue(captor.getValue().getReason().contains("threat_or_violence"));
        verify(aiAnalysisService).analyze("actual workplace threat");
    }

    @Test
    void analyzeMessageReturnsServerClassification() {
        AiAnalysisResult expected = AiAnalysisResult.flagged("AI moderation (harassment): Targeted abuse", "HIGH", 0.91);
        when(aiAnalysisService.analyze("targeted abusive text")).thenReturn(expected);

        AiAnalysisResult result = messageService.analyzeMessage("targeted abusive text");

        assertEquals(expected, result);
        verify(aiAnalysisService).analyze("targeted abusive text");
    }
}
