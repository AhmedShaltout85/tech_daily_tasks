package com.a08r.tasks_emp_complaint.controller;

import com.a08r.tasks_emp_complaint.dto.MessageResponse;
import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataRequest;
import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataResponse;
import com.a08r.tasks_emp_complaint.service.RetrieveEmpDataService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/retrieve-emp-data")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
@Slf4j
public class RetrieveEmpDataController {

    private final RetrieveEmpDataService retrieveEmpDataService;

    @PostMapping
    public ResponseEntity<RetrieveEmpDataResponse> createItem(
            @Valid @RequestBody RetrieveEmpDataRequest request) {
        RetrieveEmpDataResponse response = retrieveEmpDataService.createItem(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<RetrieveEmpDataResponse>> getAllItems() {
        return ResponseEntity.ok(retrieveEmpDataService.getAllItems());
    }

    @GetMapping("/{id}")
    public ResponseEntity<RetrieveEmpDataResponse> getItemById(@PathVariable Integer id) {
        return ResponseEntity.ok(retrieveEmpDataService.getItemById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<RetrieveEmpDataResponse> updateItem(
            @PathVariable Integer id, @Valid @RequestBody RetrieveEmpDataRequest request) {
        return ResponseEntity.ok(retrieveEmpDataService.updateItem(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<MessageResponse> deleteItem(@PathVariable Integer id) {
        retrieveEmpDataService.deleteItem(id);
        return ResponseEntity.ok(new MessageResponse("RetrieveEmpData deleted successfully!"));
    }

    @GetMapping("/emp-id/{empId}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpId(@PathVariable Integer empId) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpId(empId));
    }

    @GetMapping("/emp-name/{empName}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpName(@PathVariable String empName) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpName(empName));
    }

    @GetMapping("/emp-type/{empType}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpType(@PathVariable String empType) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpType(empType));
    }

    @GetMapping("/emp-job/{empJob}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpJob(@PathVariable String empJob) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpJob(empJob));
    }

    @GetMapping("/emp-degree/{empDegree}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpDegree(@PathVariable String empDegree) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpDegree(empDegree));
    }

    @GetMapping("/emp-location/{empLocation}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpLocation(@PathVariable String empLocation) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpLocation(empLocation));
    }

    @GetMapping("/emp-dept/{empDept}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpDept(@PathVariable String empDept) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpDept(empDept));
    }

    @GetMapping("/emp-admin/{empAdmin}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpAdmin(@PathVariable String empAdmin) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpAdmin(empAdmin));
    }

    @GetMapping("/emp-sector/{empSector}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpSector(@PathVariable String empSector) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpSector(empSector));
    }

    @GetMapping("/emp-id/{empId}/emp-dept/{empDept}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpIdAndEmpDept(
            @PathVariable Integer empId, @PathVariable String empDept) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpIdAndEmpDept(empId, empDept));
    }

    @GetMapping("/emp-dept/{empDept}/emp-location/{empLocation}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpDeptAndEmpLocation(
            @PathVariable String empDept, @PathVariable String empLocation) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpDeptAndEmpLocation(empDept, empLocation));
    }

    @GetMapping("/emp-id/{empId}/emp-location/{empLocation}")
    public ResponseEntity<List<RetrieveEmpDataResponse>> getByEmpIdAndEmpLocation(
            @PathVariable Integer empId, @PathVariable String empLocation) {
        return ResponseEntity.ok(retrieveEmpDataService.getByEmpIdAndEmpLocation(empId, empLocation));
    }
}
