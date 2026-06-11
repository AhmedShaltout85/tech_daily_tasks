package com.a08r.tasks_emp_complaint.repository;

import com.a08r.tasks_emp_complaint.entity.TaskEmpComplaint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TaskEmpComplaintRepository extends JpaRepository<TaskEmpComplaint, Long> {

    List<TaskEmpComplaint> findByAppName(String appName);

    List<TaskEmpComplaint> findByComplaintName(String complaintName);

    List<TaskEmpComplaint> findByPlaceName(String placeName);

    List<TaskEmpComplaint> findByDepartment(String department);

    List<TaskEmpComplaint> findBySubPlace(String subPlace);

    List<TaskEmpComplaint> findByEmpName(String empName);

    List<TaskEmpComplaint> findByEmpNumber(String empNumber);

    List<TaskEmpComplaint> findByEmpMobile(String empMobile);

    List<TaskEmpComplaint> findByIsEnable(Boolean isEnable);

    List<TaskEmpComplaint> findByAppNameAndDepartment(String appName, String department);

    List<TaskEmpComplaint> findByAppNameAndPlaceName(String appName, String placeName);

    List<TaskEmpComplaint> findByDepartmentAndPlaceName(String department, String placeName);

    List<TaskEmpComplaint> findByEmpNameAndAppName(String empName, String appName);
}
