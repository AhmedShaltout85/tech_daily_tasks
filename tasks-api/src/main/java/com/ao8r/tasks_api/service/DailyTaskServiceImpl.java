package com.ao8r.tasks_api.service;

import com.ao8r.tasks_api.dto.DailyTaskRequest;
import com.ao8r.tasks_api.dto.DailyTaskResponse;
import com.ao8r.tasks_api.entity.DailyTask;
import com.ao8r.tasks_api.exception.ResourceNotFoundException;
import com.ao8r.tasks_api.repository.DailyTaskRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class DailyTaskServiceImpl implements DailyTaskService {

    private final DailyTaskRepository dailyTaskRepository;

    @Override
    @Transactional
    public DailyTaskResponse createTask(DailyTaskRequest request) {
        log.debug("Creating new daily task: {}", request.getTaskTitle());

        DailyTask task = DailyTask.builder()
                .taskTitle(request.getTaskTitle())
                .taskStatus(request.getTaskStatus())
                .appName(request.getAppName())
                .visitPlace(request.getVisitPlace())
                .subPlace(request.getSubPlace() != null ? request.getSubPlace() : "none")
                .assignedTo(request.getAssignedTo())
                .assignedBy(request.getAssignedBy())
                .coOperator(request.getCoOperator() != null ? request.getCoOperator() : List.of())
                .expectedCompletionDate(request.getExpectedCompletionDate())
                .taskPriority(request.getTaskPriority())
                .taskNote(request.getTaskNote() != null ? request.getTaskNote() : "none")
                .isRemote(request.getIsRemote() != null ? request.getIsRemote() : false)
                .build();

        DailyTask savedTask = dailyTaskRepository.save(task);
        log.info("Daily task created successfully with id: {}", savedTask.getId());

        return mapToResponse(savedTask);
    }

    @Override
    public List<DailyTaskResponse> getAllTasks() {
        log.debug("Fetching all daily tasks");
        return dailyTaskRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public DailyTaskResponse getTaskById(Long id) {
        log.debug("Fetching daily task by id: {}", id);
        DailyTask task = dailyTaskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Daily task not found with id: " + id));
        return mapToResponse(task);
    }

    @Override
    @Transactional
    public DailyTaskResponse updateTask(Long id, DailyTaskRequest request) {
        log.debug("Updating daily task with id: {}", id);

        DailyTask task = dailyTaskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Daily task not found with id: " + id));

        task.setTaskTitle(request.getTaskTitle());
        task.setTaskStatus(request.getTaskStatus());
        task.setAppName(request.getAppName());
        task.setVisitPlace(request.getVisitPlace());
        task.setSubPlace(request.getSubPlace() != null ? request.getSubPlace() : "none");
        task.setAssignedTo(request.getAssignedTo());
        task.setAssignedBy(request.getAssignedBy());
        task.setCoOperator(request.getCoOperator() != null ? request.getCoOperator() : Collections.emptyList());
        task.setExpectedCompletionDate(request.getExpectedCompletionDate());
        task.setTaskPriority(request.getTaskPriority());
        task.setTaskNote(request.getTaskNote() != null ? request.getTaskNote() : "none");
        task.setIsRemote(request.getIsRemote() != null ? request.getIsRemote() : false);
        task.setIsRemote(request.getIsRemote());

        DailyTask updatedTask = dailyTaskRepository.save(task);
        log.info("Daily task updated successfully with id: {}", updatedTask.getId());

        return mapToResponse(updatedTask);
    }

    @Override
    @Transactional
    public void deleteTask(Long id) {
        log.debug("Deleting daily task with id: {}", id);

        if (!dailyTaskRepository.existsById(id)) {
            throw new ResourceNotFoundException("Daily task not found with id: " + id);
        }

        dailyTaskRepository.deleteById(id);
        log.info("Daily task deleted successfully with id: {}", id);
    }

    @Override
    public List<DailyTaskResponse> getTasksByAssignedTo(String assignedTo) {
        log.debug("Fetching daily tasks assigned to: {}", assignedTo);
        return dailyTaskRepository.findByAssignedTo(assignedTo).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<DailyTaskResponse> getTasksByAssignedBy(String assignedBy) {
        log.debug("Fetching daily tasks assigned by: {}", assignedBy);
        return dailyTaskRepository.findByAssignedBy(assignedBy).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<DailyTaskResponse> getTasksByAppName(String appName) {
        log.debug("Fetching daily tasks for app: {}", appName);
        return dailyTaskRepository.findByAppName(appName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<DailyTaskResponse> getTasksByStatus(boolean taskStatus) {
        log.debug("Fetching daily tasks by status: {}", taskStatus);
        return dailyTaskRepository.findByTaskStatus(taskStatus).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<DailyTaskResponse> getTasksByPriority(String taskPriority) {
        log.debug("Fetching daily tasks by priority: {}", taskPriority);
        return dailyTaskRepository.findByTaskPriority(taskPriority).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private DailyTaskResponse mapToResponse(DailyTask task) {
        return DailyTaskResponse.builder()
                .id(task.getId())
                .taskTitle(task.getTaskTitle())
                .taskStatus(task.isTaskStatus())
                .appName(task.getAppName())
                .visitPlace(task.getVisitPlace())
                .subPlace(task.getSubPlace())
                .assignedTo(task.getAssignedTo())
                .assignedBy(task.getAssignedBy())
                .coOperator(task.getCoOperator())
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .expectedCompletionDate(task.getExpectedCompletionDate())
                .taskPriority(task.getTaskPriority())
                .taskNote(task.getTaskNote())
                .isRemote(task.getIsRemote())
                .build();
    }
}
