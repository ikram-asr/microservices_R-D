package com.rd.finance.service;

import com.rd.finance.dto.BudgetRequest;
import com.rd.finance.dto.BudgetResponse;
import com.rd.finance.dto.ExpenseRequest;
import com.rd.finance.model.Budget;
import com.rd.finance.model.Expense;
import com.rd.finance.repository.BudgetRepository;
import com.rd.finance.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class FinanceService {

    @Autowired
    private BudgetRepository budgetRepository;

    @Autowired
    private ExpenseRepository expenseRepository;

    public List<BudgetResponse> getAllBudgets() {
        return budgetRepository.findAll().stream()
                .map(this::toBudgetResponse)
                .collect(Collectors.toList());
    }

    public List<BudgetResponse> getBudgetsByProject(Long projectId) {
        return budgetRepository.findByProjectId(projectId).stream()
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
        budget.setProjectId(request.getProjectId());
        budget.setAllocatedAmount(request.getAllocatedAmount());
        budget.setCurrency(request.getCurrency());
        budget.setFiscalYear(request.getFiscalYear());
        budget.setSpentAmount(BigDecimal.ZERO);

        budget = budgetRepository.save(budget);
        return toBudgetResponse(budget);
    }

    @Transactional
    public Expense createExpense(ExpenseRequest request, Long userId) {
        Expense expense = new Expense();
        expense.setProjectId(request.getProjectId());
        expense.setBudgetId(request.getBudgetId());
        expense.setAmount(request.getAmount());
        expense.setDescription(request.getDescription());
        expense.setCategory(request.getCategory());
        expense.setCurrency(request.getCurrency());
        expense.setCreatedBy(userId);

        expense = expenseRepository.save(expense);

        // Update budget spent amount
        if (request.getBudgetId() != null) {
            Budget budget = budgetRepository.findById(request.getBudgetId())
                    .orElseThrow(() -> new RuntimeException("Budget not found"));
            budget.setSpentAmount(budget.getSpentAmount().add(request.getAmount()));
            budgetRepository.save(budget);
        }

        return expense;
    }

    public List<Expense> getExpensesByProject(Long projectId) {
        return expenseRepository.findByProjectId(projectId);
    }

    private BudgetResponse toBudgetResponse(Budget budget) {
        return new BudgetResponse(
                budget.getId(),
                budget.getProjectId(),
                budget.getAllocatedAmount(),
                budget.getSpentAmount(),
                budget.getCurrency(),
                budget.getFiscalYear(),
                budget.getCreatedAt(),
                budget.getUpdatedAt()
        );
    }
}

