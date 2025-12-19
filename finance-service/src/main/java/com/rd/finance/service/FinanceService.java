package com.rd.finance.service;

import com.rd.finance.dto.*;
import com.rd.finance.model.Budget;
import com.rd.finance.model.Expense;
import com.rd.finance.model.Team;
import com.rd.finance.repository.BudgetRepository;
import com.rd.finance.repository.ExpenseRepository;
import com.rd.finance.repository.TeamRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class FinanceService {

    @Autowired
    private BudgetRepository budgetRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private TeamRepository teamRepository;

    // Team methods
    public List<TeamResponse> getAllTeams() {
        return teamRepository.findAll().stream()
                .map(this::toTeamResponse)
                .collect(Collectors.toList());
    }

    public TeamResponse getTeamById(Long id) {
        Team team = teamRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Team not found"));
        return toTeamResponse(team);
    }

    @Transactional
    public TeamResponse createTeam(TeamRequest request) {
        Team team = new Team();
        team.setNom(request.getNom());
        team = teamRepository.save(team);
        return toTeamResponse(team);
    }

    // Budget methods
    public List<BudgetResponse> getAllBudgets() {
        return budgetRepository.findAll().stream()
                .map(this::toBudgetResponse)
                .collect(Collectors.toList());
    }

    public List<BudgetResponse> getBudgetsByProject(Long idProject) {
        return budgetRepository.findByIdProject(idProject).stream()
                .map(this::toBudgetResponse)
                .collect(Collectors.toList());
    }

    public BudgetResponse getBudgetById(Long id) {
        Budget budget = budgetRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Budget not found"));
        return toBudgetResponse(budget);
    }

    @Transactional
    public BudgetResponse createBudget(BudgetRequest request) {
        Budget budget = new Budget();
        budget.setIdProject(request.getIdProject());
        budget.setMontant(request.getMontant());
        budget = budgetRepository.save(budget);
        return toBudgetResponse(budget);
    }

    // Expense methods
    public List<ExpenseResponse> getAllExpenses() {
        return expenseRepository.findAll().stream()
                .map(this::toExpenseResponse)
                .collect(Collectors.toList());
    }

    public List<ExpenseResponse> getExpensesByProject(Long idProject) {
        return expenseRepository.findByIdProject(idProject).stream()
                .map(this::toExpenseResponse)
                .collect(Collectors.toList());
    }

    public ExpenseResponse getExpenseById(Long id) {
        Expense expense = expenseRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Expense not found"));
        return toExpenseResponse(expense);
    }

    @Transactional
    public ExpenseResponse createExpense(ExpenseRequest request) {
        Expense expense = new Expense();
        expense.setIdProject(request.getIdProject());
        expense.setIdTeam(request.getIdTeam());
        expense.setMontant(request.getMontant());
        expense = expenseRepository.save(expense);
        return toExpenseResponse(expense);
    }

    // Mappers
    private TeamResponse toTeamResponse(Team team) {
        return new TeamResponse(
                team.getIdTeam(),
                team.getNom(),
                team.getCreatedAt(),
                team.getUpdatedAt()
        );
    }

    private BudgetResponse toBudgetResponse(Budget budget) {
        return new BudgetResponse(
                budget.getIdBudget(),
                budget.getIdProject(),
                budget.getMontant(),
                budget.getCreatedAt(),
                budget.getUpdatedAt()
        );
    }

    private ExpenseResponse toExpenseResponse(Expense expense) {
        return new ExpenseResponse(
                expense.getIdExpense(),
                expense.getIdProject(),
                expense.getIdTeam(),
                expense.getMontant(),
                expense.getCreatedAt()
        );
    }
}

