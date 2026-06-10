package com.a08r.tasks_emp_complaint.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TaskEmpComplaintResponse {

    private Long id;
    private String appName;
    private String complaintName;
    private String placeName;
    private String department;
    private String subPlace;
    private String empName;
    private Integer empNumber;
    private Integer empMobile;
    private Boolean isEnable;
    private LocalDateTime createdAt;
}
