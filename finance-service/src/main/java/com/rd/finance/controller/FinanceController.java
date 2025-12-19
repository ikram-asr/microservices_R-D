package com.rd.finance.controller;

import com.rd.finance.dto.*;
import com.rd.finance.service.FinanceService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/finance")
public class FinanceController {

    @Autowired
    private FinanceService financeService;

    // Team endpoints
    @GetMapping("/teams")
    public ResponseEntity<List<TeamResponse>> getAllTeams() {
        return ResponseEntity.ok(financeService.getAllTeams());
    }

    @GetMapping("/teams/{id}")
    public ResponseEntity<TeamResponse> getTeamById(@PathVariable Long id) {
        try {
            TeamResponse team = financeService.getTeamById(id);
            return ResponseEntity.ok(team);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/teams")
    public ResponseEntity<TeamResponse> createTeam(@Valid @RequestBody TeamRequest request) {
        try {
            TeamResponse team = financeService.createTeam(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(team);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Budget endpoints
    @GetMapping("/budgets")
    public ResponseEntity<List<BudgetResponse>> getAllBudgets() {
        return ResponseEntity.ok(financeService.getAllBudgets());
    }

    @GetMapping("/budgets/project/{idProject}")
    public ResponseEntity<List<BudgetResponse>> getBudgetsByProject(@PathVariable Long idProject) {
        return ResponseEntity.ok(financeService.getBudgetsByProject(idProject));
    }

    @GetMapping("/budgets/{id}")
    public ResponseEntity<BudgetResponse> getBudgetById(@PathVariable Long id) {
        try {
            BudgetResponse budget = financeService.getBudgetById(id);
            return ResponseEntity.ok(budget);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/budgets")
    public ResponseEntity<BudgetResponse> createBudget(@Valid @RequestBody BudgetRequest request) {
        try {
            BudgetResponse budget = financeService.createBudget(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(budget);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }

    // Expense endpoints
    @GetMapping("/expenses")
    public ResponseEntity<List<ExpenseResponse>> getAllExpenses() {
        return ResponseEntity.ok(financeService.getAllExpenses());
    }

    @GetMapping("/expenses/project/{idProject}")
    public ResponseEntity<List<ExpenseResponse>> getExpensesByProject(@PathVariable Long idProject) {
        return ResponseEntity.ok(financeService.getExpensesByProject(idProject));
    }

    @GetMapping("/expenses/{id}")
    public ResponseEntity<ExpenseResponse> getExpenseById(@PathVariable Long id) {
        try {
            ExpenseResponse expense = financeService.getExpenseById(id);
            return ResponseEntity.ok(expense);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/expenses")
    public ResponseEntity<ExpenseResponse> createExpense(@Valid @RequestBody ExpenseRequest request) {
        try {
            ExpenseResponse expense = financeService.createExpense(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(expense);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
    }
}

