package com.ao8r.tasks_api.dto;

import jakarta.validation.constraints.*;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyTaskRequest {

    @NotBlank(message = "Task title is required")
    @Size(max = 255, message = "Task title must not exceed 255 characters")
    private String taskTitle;

    @NotNull(message = "Task status is required")
    private Boolean taskStatus;

    @NotBlank(message = "App name is required")
    @Size(max = 255, message = "App name must not exceed 255 characters")
    private String appName;

    @NotBlank(message = "Visit place is required")
    @Size(max = 255, message = "Visit place must not exceed 255 characters")
    private String visitPlace;

    @Size(max = 255, message = "Sub place must not exceed 255 characters")
    private String subPlace;

    @NotBlank(message = "Assigned to is required")
    @Size(max = 255, message = "Assigned to must not exceed 255 characters")
    private String assignedTo;

    @NotBlank(message = "Assigned by is required")
    @Size(max = 255, message = "Assigned by must not exceed 255 characters")
    private String assignedBy;

    @NotBlank(message = "Co-operator is required")
    @Size(max = 255, message = "Co-operator must not exceed 255 characters")
    private String coOperator;

    @NotNull(message = "Expected completion date is required")
    private java.time.LocalDateTime expectedCompletionDate;

    @NotBlank(message = "Task priority is required")
    @Size(max = 50, message = "Task priority must not exceed 50 characters")
    private String taskPriority;

    @Size(max = 65535, message = "Task note is too long")
    private String taskNote;

    private Boolean isRemote = false;
}
