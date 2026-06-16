package com.a08r.tasks_emp_complaint.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "retrieve_emp_data")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RetrieveEmpData implements java.io.Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ID", nullable = false)
    private Integer id;

    @Column(name = "Emp_ID", nullable = false)
    private Integer empId;

    @Column(name = "Emp_Name", nullable = false, length = 255)
    private String empName;

    @Column(name = "Emp_Type", length = 255)
    private String empType;

    @Column(name = "Emp_Job", nullable = false, length = 255)
    private String empJob;

    @Column(name = "Emp_Degree", length = 255)
    private String empDegree;

    @Column(name = "Emp_Location", nullable = false, length = 255)
    private String empLocation;

    @Column(name = "Emp_Dept", length = 255)
    private String empDept;

    @Column(name = "Emp_Admin", length = 255)
    private String empAdmin;

    @Column(name = "Emp_Sector", length = 255)
    private String empSector;
}
