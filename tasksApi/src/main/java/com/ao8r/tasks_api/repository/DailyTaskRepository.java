package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.DailyTask;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DailyTaskRepository extends JpaRepository<DailyTask, Long> {

    List<DailyTask> findByAssignedTo(String assignedTo);

    List<DailyTask> findByAssignedBy(String assignedBy);

    List<DailyTask> findByAppName(String appName);

    List<DailyTask> findByTaskStatus(boolean taskStatus);

    List<DailyTask> findByTaskPriority(String taskPriority);
}