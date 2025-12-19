package com.rd.finance.repository;

import com.rd.finance.model.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    List<Expense> findByProjectId(Long projectId);
    List<Expense> findByBudgetId(Long budgetId);
}

