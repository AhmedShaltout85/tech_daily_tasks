package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.PlaceItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PlaceItemRepository extends JpaRepository<PlaceItem, Long> {

    Optional<PlaceItem> findByPlaceName(String placeName);

    @Query("SELECT p.placeName FROM PlaceItem p")
    List<String> findAllPlaceNames();
}