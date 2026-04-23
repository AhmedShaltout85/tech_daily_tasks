package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.AboutApp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AboutAppRepository extends JpaRepository<AboutApp, Long> {

    Optional<AboutApp> findByAppName(String appName);

    List<AboutApp> findByDepartment(String department);

    Optional<AboutApp> findByAppNameAndDepartment(String appName, String department);

    @Query("SELECT a.recommended FROM AboutApp a WHERE a.appName = :appName")
    List<String> findRecommendedByAppName(String appName);

    @Query("SELECT a.recommended FROM AboutApp a WHERE a.appName = :appName AND a.department = :department")
    List<String> findRecommendedByAppNameAndDepartment(String appName, String department);
}