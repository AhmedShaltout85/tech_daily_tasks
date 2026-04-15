package com.ao8r.tasks_api.controller;

import com.ao8r.tasks_api.dto.DailyTaskRequest;
import com.ao8r.tasks_api.dto.DailyTaskResponse;
import com.ao8r.tasks_api.dto.MessageResponse;
import com.ao8r.tasks_api.service.DailyTaskService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/daily-tasks")
@RequiredArgsConstructor
@Slf4j
public class DailyTaskController {

    private final DailyTaskService dailyTaskService;

    @PostMapping
    public ResponseEntity<DailyTaskResponse> createTask(@Valid @RequestBody DailyTaskRequest request) {
        log.info("Creating new daily task: {}", request.getTaskTitle());
        DailyTaskResponse response = dailyTaskService.createTask(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<DailyTaskResponse>> getAllTasks() {
        log.debug("Fetching all daily tasks");
        List<DailyTaskResponse> tasks = dailyTaskService.getAllTasks();
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/{id}")
    public ResponseEntity<DailyTaskResponse> getTaskById(@PathVariable Long id) {
        log.debug("Fetching daily task by id: {}", id);
        DailyTaskResponse response = dailyTaskService.getTaskById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<DailyTaskResponse> updateTask(@PathVariable Long id, 
                                                 @Valid @RequestBody DailyTaskRequest request) {
        log.info("Updating daily task with id: {}", id);
        DailyTaskResponse response = dailyTaskService.updateTask(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteTask(@PathVariable Long id) {
        log.info("Deleting daily task with id: {}", id);
        dailyTaskService.deleteTask(id);
        return ResponseEntity.ok(new MessageResponse("Daily task deleted successfully!"));
    }

    @GetMapping("/assigned-to/{username}")
    public ResponseEntity<List<DailyTaskResponse>> getTasksByAssignedTo(@PathVariable String username) {
        log.debug("Fetching daily tasks assigned to: {}", username);
        List<DailyTaskResponse> tasks = dailyTaskService.getTasksByAssignedTo(username);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/assigned-by/{username}")
    public ResponseEntity<List<DailyTaskResponse>> getTasksByAssignedBy(@PathVariable String username) {
        log.debug("Fetching daily tasks assigned by: {}", username);
        List<DailyTaskResponse> tasks = dailyTaskService.getTasksByAssignedBy(username);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/app/{appName}")
    public ResponseEntity<List<DailyTaskResponse>> getTasksByAppName(@PathVariable String appName) {
        log.debug("Fetching daily tasks for app: {}", appName);
        List<DailyTaskResponse> tasks = dailyTaskService.getTasksByAppName(appName);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/status/{taskStatus}")
    public ResponseEntity<List<DailyTaskResponse>> getTasksByStatus(@PathVariable boolean taskStatus) {
        log.debug("Fetching daily tasks by status: {}", taskStatus);
        List<DailyTaskResponse> tasks = dailyTaskService.getTasksByStatus(taskStatus);
        return ResponseEntity.ok(tasks);
    }

    @GetMapping("/priority/{taskPriority}")
    public ResponseEntity<List<DailyTaskResponse>> getTasksByPriority(@PathVariable String taskPriority) {
        log.debug("Fetching daily tasks by priority: {}", taskPriority);
        List<DailyTaskResponse> tasks = dailyTaskService.getTasksByPriority(taskPriority);
        return ResponseEntity.ok(tasks);
    }
}