package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintRequest;
import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintResponse;
import com.a08r.tasks_emp_complaint.entity.TaskEmpComplaint;
import com.a08r.tasks_emp_complaint.exception.ResourceNotFoundException;
import com.a08r.tasks_emp_complaint.repository.TaskEmpComplaintRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskEmpComplaintServiceImpl implements TaskEmpComplaintService {

    private final TaskEmpComplaintRepository taskEmpComplaintRepository;

    @Override
    @Transactional
    public TaskEmpComplaintResponse createItem(TaskEmpComplaintRequest request) {
        log.debug("Creating new employee complaint: {}", request.getComplaintName());

        TaskEmpComplaint item = TaskEmpComplaint.builder()
                .appName(request.getAppName())
                .complaintName(request.getComplaintName())
                .placeName(request.getPlaceName())
                .department(request.getDepartment())
                .subPlace(request.getSubPlace() != null ? request.getSubPlace() : "none")
                .empName(request.getEmpName())
                .empNumber(request.getEmpNumber())
                .empMobile(request.getEmpMobile())
                .isEnable(request.getIsEnable() != null ? request.getIsEnable() : true)
                .build();

        TaskEmpComplaint savedItem = taskEmpComplaintRepository.save(item);
        log.info("Employee complaint created successfully with id: {}", savedItem.getId());

        return mapToResponse(savedItem);
    }

    @Override
    public List<TaskEmpComplaintResponse> getAllItems() {
        log.debug("Fetching all employee complaints");
        return taskEmpComplaintRepository.findAll().stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public TaskEmpComplaintResponse getItemById(Long id) {
        log.debug("Fetching employee complaint by id: {}", id);
        TaskEmpComplaint item = taskEmpComplaintRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee complaint not found with id: " + id));
        return mapToResponse(item);
    }

    @Override
    @Transactional
    public TaskEmpComplaintResponse updateItem(Long id, TaskEmpComplaintRequest request) {
        log.debug("Updating employee complaint with id: {}", id);

        TaskEmpComplaint item = taskEmpComplaintRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee complaint not found with id: " + id));

        item.setAppName(request.getAppName());
        item.setComplaintName(request.getComplaintName());
        item.setPlaceName(request.getPlaceName());
        item.setDepartment(request.getDepartment());
        item.setSubPlace(request.getSubPlace() != null ? request.getSubPlace() : "none");
        item.setEmpName(request.getEmpName());
        item.setEmpNumber(request.getEmpNumber());
        item.setEmpMobile(request.getEmpMobile());
        item.setIsEnable(request.getIsEnable() != null ? request.getIsEnable() : true);

        TaskEmpComplaint updatedItem = taskEmpComplaintRepository.save(item);
        log.info("Employee complaint updated successfully with id: {}", updatedItem.getId());

        return mapToResponse(updatedItem);
    }

    @Override
    @Transactional
    public void deleteItem(Long id) {
        log.debug("Deleting employee complaint with id: {}", id);

        if (!taskEmpComplaintRepository.existsById(id)) {
            throw new ResourceNotFoundException("Employee complaint not found with id: " + id);
        }

        taskEmpComplaintRepository.deleteById(id);
        log.info("Employee complaint deleted successfully with id: {}", id);
    }

    // Filter implementations
    @Override
    public List<TaskEmpComplaintResponse> getByAppName(String appName) {
        return taskEmpComplaintRepository.findByAppName(appName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByComplaintName(String complaintName) {
        return taskEmpComplaintRepository.findByComplaintName(complaintName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByPlaceName(String placeName) {
        return taskEmpComplaintRepository.findByPlaceName(placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByDepartment(String department) {
        return taskEmpComplaintRepository.findByDepartment(department).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getBySubPlace(String subPlace) {
        return taskEmpComplaintRepository.findBySubPlace(subPlace).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByEmpName(String empName) {
        return taskEmpComplaintRepository.findByEmpName(empName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByEmpNumber(Integer empNumber) {
        return taskEmpComplaintRepository.findByEmpNumber(empNumber).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByEmpMobile(Integer empMobile) {
        return taskEmpComplaintRepository.findByEmpMobile(empMobile).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByIsEnable(Boolean isEnable) {
        return taskEmpComplaintRepository.findByIsEnable(isEnable).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByAppNameAndDepartment(String appName, String department) {
        return taskEmpComplaintRepository.findByAppNameAndDepartment(appName, department).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByAppNameAndPlaceName(String appName, String placeName) {
        return taskEmpComplaintRepository.findByAppNameAndPlaceName(appName, placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByDepartmentAndPlaceName(String department, String placeName) {
        return taskEmpComplaintRepository.findByDepartmentAndPlaceName(department, placeName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    @Override
    public List<TaskEmpComplaintResponse> getByEmpNameAndAppName(String empName, String appName) {
        return taskEmpComplaintRepository.findByEmpNameAndAppName(empName, appName).stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    private TaskEmpComplaintResponse mapToResponse(TaskEmpComplaint item) {
        return TaskEmpComplaintResponse.builder()
                .id(item.getId())
                .appName(item.getAppName())
                .complaintName(item.getComplaintName())
                .placeName(item.getPlaceName())
                .department(item.getDepartment())
                .subPlace(item.getSubPlace())
                .empName(item.getEmpName())
                .empNumber(item.getEmpNumber())
                .empMobile(item.getEmpMobile())
                .isEnable(item.getIsEnable())
                .createdAt(item.getCreatedAt())
                .build();
    }
}
