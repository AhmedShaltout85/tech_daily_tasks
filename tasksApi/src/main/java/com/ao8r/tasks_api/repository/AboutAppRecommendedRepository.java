package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.AboutAppRecommended;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AboutAppRecommendedRepository extends JpaRepository<AboutAppRecommended, Long> {

    List<AboutAppRecommended> findByAppName(String appName);

    @Query("SELECT r FROM AboutAppRecommended r WHERE r.appName = :appName")
    List<AboutAppRecommended> findAllByAppName(String appName);

    @Query("SELECT r.recommendedValue FROM AboutAppRecommended r WHERE r.appName = :appName")
    List<String> findRecommendedValuesByAppName(String appName);
}