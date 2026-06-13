package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintRequest;
import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintResponse;

import java.util.List;

public interface TaskEmpComplaintService {

    TaskEmpComplaintResponse createItem(TaskEmpComplaintRequest request);

    List<TaskEmpComplaintResponse> getAllItems();

    TaskEmpComplaintResponse getItemById(Long id);

    TaskEmpComplaintResponse updateItem(Long id, TaskEmpComplaintRequest request);

    void deleteItem(Long id);

    // Filters
    List<TaskEmpComplaintResponse> getByAppName(String appName);

    List<TaskEmpComplaintResponse> getByComplaintName(String complaintName);

    List<TaskEmpComplaintResponse> getByPlaceName(String placeName);

    List<TaskEmpComplaintResponse> getByDepartment(String department);

    List<TaskEmpComplaintResponse> getBySubPlace(String subPlace);

    List<TaskEmpComplaintResponse> getByEmpName(String empName);

    List<TaskEmpComplaintResponse> getByEmpNumber(String empNumber);

    List<TaskEmpComplaintResponse> getByEmpMobile(String empMobile);

    List<TaskEmpComplaintResponse> getByIsEnable(Boolean isEnable);

    List<TaskEmpComplaintResponse> getByAppNameAndDepartment(String appName, String department);

    List<TaskEmpComplaintResponse> getByAppNameAndPlaceName(String appName, String placeName);

    List<TaskEmpComplaintResponse> getByDepartmentAndPlaceName(String department, String placeName);

    List<TaskEmpComplaintResponse> getByEmpNameAndAppName(String empName, String appName);

    List<TaskEmpComplaintResponse> getByDepartmentAndIsEnable(String department, Boolean isEnable);
}
