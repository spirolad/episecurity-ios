package com.episecurity.epibrother.repository;

import com.episecurity.epibrother.model.entity.Message;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    List<Message> findAllByOrderByCreatedAtDesc();
    List<Message> findBySenderIdOrderByCreatedAtDesc(Long senderId);
    List<Message> findByRecipientIdOrderByCreatedAtDesc(Long recipientId);
}
