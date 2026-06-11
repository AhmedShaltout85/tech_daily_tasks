package com.a08r.tasks_emp_complaint.repository;

import com.a08r.tasks_emp_complaint.entity.AboutApp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AboutAppRepository extends JpaRepository<AboutApp, Long> {

    List<AboutApp> findByAppName(String appName);

    List<AboutApp> findByDepartment(String department);
}
