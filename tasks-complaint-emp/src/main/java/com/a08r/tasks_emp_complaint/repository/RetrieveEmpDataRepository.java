package com.a08r.tasks_emp_complaint.repository;

import com.a08r.tasks_emp_complaint.entity.RetrieveEmpData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RetrieveEmpDataRepository extends JpaRepository<RetrieveEmpData, Integer> {

    List<RetrieveEmpData> findByEmpId(Integer empId);

    List<RetrieveEmpData> findByEmpName(String empName);

    List<RetrieveEmpData> findByEmpType(String empType);

    List<RetrieveEmpData> findByEmpJob(String empJob);

    List<RetrieveEmpData> findByEmpDegree(String empDegree);

    List<RetrieveEmpData> findByEmpLocation(String empLocation);

    List<RetrieveEmpData> findByEmpDept(String empDept);

    List<RetrieveEmpData> findByEmpAdmin(String empAdmin);

    List<RetrieveEmpData> findByEmpSector(String empSector);

    List<RetrieveEmpData> findByEmpIdAndEmpDept(Integer empId, String empDept);

    List<RetrieveEmpData> findByEmpDeptAndEmpLocation(String empDept, String empLocation);

    List<RetrieveEmpData> findByEmpIdAndEmpLocation(Integer empId, String empLocation);
}
