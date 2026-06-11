package com.a08r.tasks_emp_complaint.repository;

import com.a08r.tasks_emp_complaint.entity.PlaceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PlaceItemRepository extends JpaRepository<PlaceItem, Long> {

    List<PlaceItem> findByPlaceName(String placeName);
}
