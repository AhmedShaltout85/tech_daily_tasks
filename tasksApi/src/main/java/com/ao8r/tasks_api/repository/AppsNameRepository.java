package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.AppsName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AppsNameRepository extends JpaRepository<AppsName, Long> {
    List<AppsName> findByDepartment(String department);
}