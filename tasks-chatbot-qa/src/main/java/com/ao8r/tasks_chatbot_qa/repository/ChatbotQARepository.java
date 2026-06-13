package com.ao8r.tasks_chatbot_qa.repository;

import com.ao8r.tasks_chatbot_qa.entity.ChatbotQA;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatbotQARepository extends JpaRepository<ChatbotQA, Long> {

    List<ChatbotQA> findByIsActiveTrueOrderByDisplayOrderAsc();

    List<ChatbotQA> findByCategoryAndIsActiveTrueOrderByDisplayOrderAsc(String category);

    List<ChatbotQA> findByIsActiveTrue();

    List<ChatbotQA> findAllByOrderByDisplayOrderAsc();

    @Query("SELECT DISTINCT q.category FROM ChatbotQA q WHERE q.isActive = true AND q.category IS NOT NULL ORDER BY q.category")
    List<String> findDistinctActiveCategories();
}
