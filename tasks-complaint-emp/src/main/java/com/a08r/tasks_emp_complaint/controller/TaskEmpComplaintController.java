package com.a08r.tasks_emp_complaint.controller;

import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintRequest;
import com.a08r.tasks_emp_complaint.dto.TaskEmpComplaintResponse;
import com.a08r.tasks_emp_complaint.dto.MessageResponse;
import com.a08r.tasks_emp_complaint.service.TaskEmpComplaintService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/emp-complaints")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class TaskEmpComplaintController {

    private final TaskEmpComplaintService taskEmpComplaintService;

    @PostMapping
    public ResponseEntity<TaskEmpComplaintResponse> createItem(@Valid @RequestBody TaskEmpComplaintRequest request) {
        log.info("Creating new employee complaint: {}", request.getComplaintName());
        TaskEmpComplaintResponse response = taskEmpComplaintService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<TaskEmpComplaintResponse>> getAllItems() {
        log.debug("Fetching all employee complaints");
        List<TaskEmpComplaintResponse> items = taskEmpComplaintService.getAllItems();
        return ResponseEntity.ok(items);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TaskEmpComplaintResponse> getItemById(@PathVariable Long id) {
        log.debug("Fetching employee complaint by id: {}", id);
        TaskEmpComplaintResponse response = taskEmpComplaintService.getItemById(id);
        return ResponseEntity.ok(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<TaskEmpComplaintResponse> updateItem(@PathVariable Long id,
                                                   @Valid @RequestBody TaskEmpComplaintRequest request) {
        log.info("Updating employee complaint with id: {}", id);
        TaskEmpComplaintResponse response = taskEmpComplaintService.updateItem(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Long id) {
        log.info("Deleting employee complaint with id: {}", id);
        taskEmpComplaintService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("Employee complaint deleted successfully!"));
    }

    // Filter endpoints
    @GetMapping("/app/{appName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByAppName(@PathVariable String appName) {
        log.debug("Fetching by app name: {}", appName);
        return ResponseEntity.ok(taskEmpComplaintService.getByAppName(appName));
    }

    @GetMapping("/complaint/{complaintName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByComplaintName(@PathVariable String complaintName) {
        log.debug("Fetching by complaint name: {}", complaintName);
        return ResponseEntity.ok(taskEmpComplaintService.getByComplaintName(complaintName));
    }

    @GetMapping("/place/{placeName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByPlaceName(@PathVariable String placeName) {
        log.debug("Fetching by place name: {}", placeName);
        return ResponseEntity.ok(taskEmpComplaintService.getByPlaceName(placeName));
    }

    @GetMapping("/department/{department}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByDepartment(@PathVariable String department) {
        log.debug("Fetching by department: {}", department);
        return ResponseEntity.ok(taskEmpComplaintService.getByDepartment(department));
    }

    @GetMapping("/sub-place/{subPlace}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getBySubPlace(@PathVariable String subPlace) {
        log.debug("Fetching by sub place: {}", subPlace);
        return ResponseEntity.ok(taskEmpComplaintService.getBySubPlace(subPlace));
    }

    @GetMapping("/emp-name/{empName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByEmpName(@PathVariable String empName) {
        log.debug("Fetching by employee name: {}", empName);
        return ResponseEntity.ok(taskEmpComplaintService.getByEmpName(empName));
    }

    @GetMapping("/emp-number/{empNumber}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByEmpNumber(@PathVariable String empNumber) {
        log.debug("Fetching by employee number: {}", empNumber);
        return ResponseEntity.ok(taskEmpComplaintService.getByEmpNumber(empNumber));
    }

    @GetMapping("/emp-mobile/{empMobile}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByEmpMobile(@PathVariable String empMobile) {
        log.debug("Fetching by employee mobile: {}", empMobile);
        return ResponseEntity.ok(taskEmpComplaintService.getByEmpMobile(empMobile));
    }

    @GetMapping("/enable/{isEnable}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByIsEnable(@PathVariable Boolean isEnable) {
        log.debug("Fetching by enabled status: {}", isEnable);
        return ResponseEntity.ok(taskEmpComplaintService.getByIsEnable(isEnable));
    }

    @GetMapping("/app/{appName}/department/{department}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByAppNameAndDepartment(
            @PathVariable String appName, @PathVariable String department) {
        log.debug("Fetching by app name and department: {}, {}", appName, department);
        return ResponseEntity.ok(taskEmpComplaintService.getByAppNameAndDepartment(appName, department));
    }

    @GetMapping("/app/{appName}/place/{placeName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByAppNameAndPlaceName(
            @PathVariable String appName, @PathVariable String placeName) {
        log.debug("Fetching by app name and place name: {}, {}", appName, placeName);
        return ResponseEntity.ok(taskEmpComplaintService.getByAppNameAndPlaceName(appName, placeName));
    }

    @GetMapping("/department/{department}/place/{placeName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByDepartmentAndPlaceName(
            @PathVariable String department, @PathVariable String placeName) {
        log.debug("Fetching by department and place name: {}, {}", department, placeName);
        return ResponseEntity.ok(taskEmpComplaintService.getByDepartmentAndPlaceName(department, placeName));
    }

    @GetMapping("/emp-name/{empName}/app/{appName}")
    public ResponseEntity<List<TaskEmpComplaintResponse>> getByEmpNameAndAppName(
            @PathVariable String empName, @PathVariable String appName) {
        log.debug("Fetching by employee name and app name: {}, {}", empName, appName);
        return ResponseEntity.ok(taskEmpComplaintService.getByEmpNameAndAppName(empName, appName));
    }
}
