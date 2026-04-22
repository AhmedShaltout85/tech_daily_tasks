package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.DailyTaskRequest;
import com.ao8r.tasks_api.dto.DailyTaskResponse;

import java.util.List;

public interface DailyTaskService {

    DailyTaskResponse createTask(DailyTaskRequest request);

    List<DailyTaskResponse> getAllTasks();

    DailyTaskResponse getTaskById(Long id);

    DailyTaskResponse updateTask(Long id, DailyTaskRequest request);

    void deleteTask(Long id);

    List<DailyTaskResponse> getTasksByAssignedTo(String assignedTo);

    List<DailyTaskResponse> getTasksByAssignedBy(String assignedBy);

    List<DailyTaskResponse> getTasksByAppName(String appName);

    List<DailyTaskResponse> getTasksByStatus(boolean taskStatus);

    List<DailyTaskResponse> getTasksByPriority(String taskPriority);

    List<DailyTaskResponse> getTasksByAssignedToAndIsRemote(String assignedTo, boolean isRemote);

    List<DailyTaskResponse> getTasksByIsRemote(boolean isRemote);
}