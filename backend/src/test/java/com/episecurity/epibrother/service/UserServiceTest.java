package com.episecurity.epibrother.service;

import com.episecurity.epibrother.model.entity.User;
import com.episecurity.epibrother.model.enums.RoleType;
import com.episecurity.epibrother.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.*;

class UserServiceTest {

    private UserRepository userRepository;
    private UserService userService;
    private User employee;
    private User manager;
    private User admin;
    private User colleague;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        userService = new UserService(userRepository, new BCryptPasswordEncoder());

        employee = new User("alice", "pwd", RoleType.EMPLOYEE, "Alice Martin");
        employee.setId(1L);
        manager = new User("manager", "pwd", RoleType.MANAGER, "Jean Manager");
        manager.setId(2L);
        admin = new User("admin", "pwd", RoleType.ADMIN, "Admin User");
        admin.setId(3L);
        colleague = new User("bob", "pwd", RoleType.EMPLOYEE, "Bob Durand");
        colleague.setId(4L);

        employee.setManager(manager);
        colleague.setManager(manager);
        when(userRepository.findByUsername("alice")).thenReturn(Optional.of(employee));
        when(userRepository.findAll()).thenReturn(List.of(employee, manager, admin, colleague));
        when(userRepository.findByManagerId(2L)).thenReturn(List.of(employee, colleague));
    }

    @Test
    void employeeSeesManagerAdminAndColleague() {
        var contacts = userService.getColleagues("alice");

        assertEquals(List.of(2L, 3L, 4L), contacts.stream().map(response -> response.getId()).toList());
    }
}
