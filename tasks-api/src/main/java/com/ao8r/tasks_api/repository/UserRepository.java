package com.ao8r.tasks_api.repository;

import com.ao8r.tasks_api.entity.Role;
import com.ao8r.tasks_api.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUsername(String username);

    Boolean existsByUsername(String username);

    List<User> findByRole(Role role);

    List<User> findByRoleAndIsEnabled(Role role, boolean isEnabled);

    List<User> findByDepartment(String department);
}
