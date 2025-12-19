package com.rd.finance.dao.repositories;

import com.rd.finance.dao.entities.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long> {
    List<Expense> findByIdProject(Long idProject);
    List<Expense> findByIdTeam(Long idTeam);
}

