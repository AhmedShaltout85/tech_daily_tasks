package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.PreventiveItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PreventiveItemRepository extends JpaRepository<PreventiveItem, Long> {

    Optional<PreventiveItem> findByAppName(String appName);

    @Query("SELECT p.action FROM PreventiveItem p WHERE p.appName = :appName")
    List<String> findActionByAppName(String appName);
}