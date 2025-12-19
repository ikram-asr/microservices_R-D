package com.rd.finance.dao.repositories;

import com.rd.finance.dao.entities.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, Long> {
    List<Budget> findByIdProject(Long idProject);
}

