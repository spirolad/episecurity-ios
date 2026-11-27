package com.episecurity.epibrother.ai;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;
import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.content;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withServerError;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class AiAnalysisServiceTest {

    private AiAnalysisService aiAnalysisService;
    private MockRestServiceServer server;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @BeforeEach
    void setUp() {
        RestClient.Builder builder = RestClient.builder();
        server = MockRestServiceServer.bindTo(builder).build();
        aiAnalysisService = new AiAnalysisService(builder, objectMapper, "http://ollama.test", "qwen2.5:3b");
    }

    @Test
    void safeMessageIsSentToOllamaAndNotFlagged() throws Exception {
        String content = "Bonjour, voici les documents pour la reunion de demain.";
        expectClassification(content, Map.of(
                "flagged", false,
                "category", "none",
                "severity", "LOW",
                "confidence", 0.98,
                "reason", "Ordinary professional conversation"));

        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertFalse(result.isFlagged());
        assertNull(result.getReason());
        assertEquals("LOW", result.getSeverity());
        server.verify();
    }

    @Test
    void policyViolationIsFlaggedUsingModelClassification() throws Exception {
        String content = "You are worthless and should leave this team.";
        expectClassification(content, Map.of(
                "flagged", true,
                "category", "harassment",
                "severity", "HIGH",
                "confidence", 0.91,
                "reason", "Targeted abusive language"));

        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertTrue(result.isFlagged());
        assertEquals("HIGH", result.getSeverity());
        assertEquals(0.91, result.getConfidenceScore());
        assertTrue(result.getReason().contains("harassment"));
        server.verify();
    }

    @Test
    void benignOrganizationMentionIsNotAutomaticallyFlagged() throws Exception {
        String content = "Rendez-vous devant le campus Epita a 14h.";
        expectClassification(content, Map.of(
                "flagged", false,
                "category", "none",
                "severity", "LOW",
                "confidence", 0.99,
                "reason", "Benign mention"));

        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertFalse(result.isFlagged());
        server.verify();
    }

    @Test
    void emptyMessageDoesNotCallModel() {
        AiAnalysisResult result = aiAnalysisService.analyze("");

        assertFalse(result.isFlagged());
        server.verify();
    }

    @Test
    void encryptedMessageIsNotSentToModel() {
        AiAnalysisResult result = aiAnalysisService.analyze("ENC:YmFzZTY0");

        assertTrue(result.isFlagged());
        assertEquals("MEDIUM", result.getSeverity());
        assertTrue(result.getReason().contains("manual review"));
        server.verify();
    }

    @Test
    void unavailableModelFlagsMessageForManualReview() {
        server.expect(requestTo("http://ollama.test/api/chat"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withServerError());

        AiAnalysisResult result = aiAnalysisService.analyze("Bonjour, peux-tu relire le document ?");

        assertTrue(result.isFlagged());
        assertEquals("MEDIUM", result.getSeverity());
        assertEquals(0.0, result.getConfidenceScore());
        assertTrue(result.getReason().contains("manual review"));
        server.verify();
    }

    private void expectClassification(String message, Map<String, Object> classification) throws Exception {
        String classificationJson = objectMapper.writeValueAsString(classification);
        String responseBody = objectMapper.writeValueAsString(Map.of(
                "message", Map.of("content", classificationJson)));
        server.expect(requestTo("http://ollama.test/api/chat"))
                .andExpect(method(HttpMethod.POST))
                .andExpect(content().string(containsString("qwen2.5:3b")))
                .andExpect(content().string(containsString(message)))
                .andRespond(withSuccess(responseBody, MediaType.APPLICATION_JSON));
    }
}
