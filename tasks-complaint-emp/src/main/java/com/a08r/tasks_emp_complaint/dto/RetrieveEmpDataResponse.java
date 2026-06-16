package com.a08r.tasks_emp_complaint.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RetrieveEmpDataResponse {
    private Integer id;
    private Integer empId;
    private String empName;
    private String empType;
    private String empJob;
    private String empDegree;
    private String empLocation;
    private String empDept;
    private String empAdmin;
    private String empSector;
}
