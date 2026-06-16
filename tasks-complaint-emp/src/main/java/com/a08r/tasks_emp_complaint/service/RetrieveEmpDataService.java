package com.a08r.tasks_emp_complaint.service;

import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataRequest;
import com.a08r.tasks_emp_complaint.dto.RetrieveEmpDataResponse;

import java.util.List;

public interface RetrieveEmpDataService {

    RetrieveEmpDataResponse createItem(RetrieveEmpDataRequest request);

    List<RetrieveEmpDataResponse> getAllItems();

    RetrieveEmpDataResponse getItemById(Integer id);

    RetrieveEmpDataResponse updateItem(Integer id, RetrieveEmpDataRequest request);

    void deleteItem(Integer id);

    List<RetrieveEmpDataResponse> getByEmpId(Integer empId);

    List<RetrieveEmpDataResponse> getByEmpName(String empName);

    List<RetrieveEmpDataResponse> getByEmpType(String empType);

    List<RetrieveEmpDataResponse> getByEmpJob(String empJob);

    List<RetrieveEmpDataResponse> getByEmpDegree(String empDegree);

    List<RetrieveEmpDataResponse> getByEmpLocation(String empLocation);

    List<RetrieveEmpDataResponse> getByEmpDept(String empDept);

    List<RetrieveEmpDataResponse> getByEmpAdmin(String empAdmin);

    List<RetrieveEmpDataResponse> getByEmpSector(String empSector);

    List<RetrieveEmpDataResponse> getByEmpIdAndEmpDept(Integer empId, String empDept);

    List<RetrieveEmpDataResponse> getByEmpDeptAndEmpLocation(String empDept, String empLocation);

    List<RetrieveEmpDataResponse> getByEmpIdAndEmpLocation(Integer empId, String empLocation);
}
