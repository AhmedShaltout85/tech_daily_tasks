package com.ao8r.tasks_api.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DailyTaskResponse {

    private Long id;
    private String taskTitle;
    private boolean taskStatus;
    private String appName;
    private String visitPlace;
    private String subPlace;
    private String assignedTo;
    private String assignedBy;
    private List<String> coOperator;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime expectedCompletionDate;
    private String taskPriority;
    private String taskNote;
    private boolean isRemote;
}
