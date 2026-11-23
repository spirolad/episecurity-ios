package com.episecurity.epibrother.ai;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class AiAnalysisServiceTest {

    private AiAnalysisService aiAnalysisService;

    @BeforeEach
    void setUp() {
        aiAnalysisService = new AiAnalysisService();
    }

    @Test
    void testMessageWithoutEpita_ShouldNotBeFlagged() {
        String content = "Bonjour, voici les documents pour la réunion de demain.";
        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertFalse(result.isFlagged());
        assertNull(result.getReason());
        assertEquals("LOW", result.getSeverity());
    }

    @Test
    void testMessageWithEpita_ExactCase_ShouldBeFlagged() {
        String content = "Je prépare un dossier confidentiel sur Epita.";
        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertTrue(result.isFlagged());
        assertNotNull(result.getReason());
        assertEquals("HIGH", result.getSeverity());
        assertTrue(result.getReason().contains("Epita"));
    }

    @Test
    void testMessageWithEpita_LowerCase_ShouldBeFlagged() {
        String content = "Rendez-vous devant le campus epita à 14h.";
        AiAnalysisResult result = aiAnalysisService.analyze(content);

        assertTrue(result.isFlagged());
        assertEquals("HIGH", result.getSeverity());
    }

    @Test
    void testEmptyMessage_ShouldNotBeFlagged() {
        AiAnalysisResult result = aiAnalysisService.analyze("");
        assertFalse(result.isFlagged());
    }
}
