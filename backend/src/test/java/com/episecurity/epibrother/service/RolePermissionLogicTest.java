package com.episecurity.epibrother.service;

import com.episecurity.epibrother.ai.AiAnalysisService;
import com.episecurity.epibrother.dto.request.SendMessageRequest;
import com.episecurity.epibrother.dto.response.MessageResponse;
import com.episecurity.epibrother.model.entity.Message;
import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.MessageRepository;
import com.episecurity.epibrother.repository.SignalementRepository;
import com.episecurity.epibrother.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class RolePermissionLogicTest {

    private MessageRepository messageRepository;
    private UserRepository userRepository;
    private SignalementRepository signalementRepository;
    private AiAnalysisService aiAnalysisService;
    private MessageService messageService;

    private User admin;
    private User manager;
    private User employeeAlice;
    private User employeeBob;

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

        admin = new User("admin", "pwd", RoleType.ADMIN, "Admin User");
        admin.setId(1L);

        manager = new User("manager_dupont", "pwd", RoleType.MANAGER, "Jean Manager");
        manager.setId(2L);

        employeeAlice = new User("alice", "pwd", RoleType.EMPLOYEE, "Alice Martin");
        employeeAlice.setId(3L);

        employeeBob = new User("bob", "pwd", RoleType.EMPLOYEE, "Bob Durand");
        employeeBob.setId(4L);

        when(userRepository.findByUsername("admin")).thenReturn(Optional.of(admin));
        when(userRepository.findByUsername("manager_dupont")).thenReturn(Optional.of(manager));
        when(userRepository.findByUsername("alice")).thenReturn(Optional.of(employeeAlice));
        when(userRepository.findByUsername("bob")).thenReturn(Optional.of(employeeBob));

        when(userRepository.findById(1L)).thenReturn(Optional.of(admin));
        when(userRepository.findById(2L)).thenReturn(Optional.of(manager));
        when(userRepository.findById(3L)).thenReturn(Optional.of(employeeAlice));
        when(userRepository.findById(4L)).thenReturn(Optional.of(employeeBob));
    }

    @Test
    void testEmployee_CanSendMessageToPerson() {
        SendMessageRequest request = new SendMessageRequest(3L, 4L, "Bonjour Bob !");

        when(messageRepository.save(any(Message.class))).thenAnswer(invocation -> {
            Message m = invocation.getArgument(0);
            m.setId(101L);
            return m;
        });

        MessageResponse response = messageService.sendMessage(request, "alice");
        assertNotNull(response);
        assertEquals(101L, response.getId());
    }

    @Test
    void testEmployee_SendMessageWithoutRecipient_ThrowsBadRequest() {
        SendMessageRequest request = new SendMessageRequest(3L, null, "Message broadcast");
        assertThrows(ResponseStatusException.class, () -> messageService.sendMessage(request, "alice"));
    }

    @Test
    void testEmployee_CannotImpersonateAnotherUser() {
        // Alice tente d'envoyer sous l'id de Bob (4L)
        SendMessageRequest request = new SendMessageRequest(4L, 2L, "Message usurpé");
        assertThrows(ResponseStatusException.class, () -> messageService.sendMessage(request, "alice"));
    }

    @Test
    void testEmployee_GetAuthorizedMessages_ReturnsOnlyMessagesWhereTarget() {
        Message msgForAlice = new Message(employeeBob, employeeAlice, "Pour Alice");
        msgForAlice.setId(201L);

        when(messageRepository.findByRecipientIdOrderByCreatedAtDesc(3L)).thenReturn(List.of(msgForAlice));

        List<MessageResponse> responses = messageService.getAuthorizedMessages("alice");
        assertEquals(1, responses.size());
        assertEquals(201L, responses.get(0).getId());
        verify(messageRepository, times(1)).findByRecipientIdOrderByCreatedAtDesc(3L);
        verify(messageRepository, never()).findAllByOrderByCreatedAtDesc();
    }

    @Test
    void testManagerAndAdmin_GetAuthorizedMessages_ReturnsAllMessages() {
        Message msg1 = new Message(employeeAlice, employeeBob, "Hello");
        when(messageRepository.findAllByOrderByCreatedAtDesc()).thenReturn(List.of(msg1));

        List<MessageResponse> adminMessages = messageService.getAuthorizedMessages("admin");
        assertEquals(1, adminMessages.size());

        List<MessageResponse> managerMessages = messageService.getAuthorizedMessages("manager_dupont");
        assertEquals(1, managerMessages.size());

        verify(messageRepository, times(2)).findAllByOrderByCreatedAtDesc();
    }

    @Test
    void testEmployee_GetMessageById_WhenRecipient_Success() {
        Message msgForAlice = new Message(employeeBob, employeeAlice, "Secret");
        msgForAlice.setId(301L);
        when(messageRepository.findById(301L)).thenReturn(Optional.of(msgForAlice));

        MessageResponse res = messageService.getAuthorizedMessageById(301L, "alice");
        assertNotNull(res);
        assertEquals(301L, res.getId());
    }

    @Test
    void testEmployee_GetMessageById_WhenNotRecipient_ThrowsForbidden() {
        Message msgForBob = new Message(employeeAlice, employeeBob, "Pour Bob uniquement");
        msgForBob.setId(302L);
        when(messageRepository.findById(302L)).thenReturn(Optional.of(msgForBob));

        // Alice essaie de lire le message destiné à Bob
        assertThrows(ResponseStatusException.class, () -> messageService.getAuthorizedMessageById(302L, "alice"));
    }

    @Test
    void testManagerAndAdmin_GetMessageById_AnyMessage_Success() {
        Message msgBetweenEmployees = new Message(employeeAlice, employeeBob, "Message interne");
        msgBetweenEmployees.setId(303L);
        when(messageRepository.findById(303L)).thenReturn(Optional.of(msgBetweenEmployees));

        // Admin peut lire
        MessageResponse adminRes = messageService.getAuthorizedMessageById(303L, "admin");
        assertNotNull(adminRes);

        // Manager peut lire
        MessageResponse managerRes = messageService.getAuthorizedMessageById(303L, "manager_dupont");
        assertNotNull(managerRes);
    }
}
