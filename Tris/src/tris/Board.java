/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package tris;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 *
 * @author annafi.kazi
 */
public class Board {
    private final char[][] board = new char[3][3];
    private boolean gameOver = false;
    private final Lock lock = new ReentrantLock();

    public Board() {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                board[i][j] = '-';
            }
        }
    }

    public void printBoard() {
        lock.lock();
        try {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    System.out.print(" " + board[i][j] + " ");
                if (j < 2) System.out.print("|");
                }
                System.out.println();
                if (i < 2) System.out.println("---+---+---");
            }
            System.out.println();
        } finally {
            lock.unlock();
        }
    }

    public boolean makeMove(int row, int col, char symbol) {
        lock.lock();
        try {
            if (board[row][col] == '-' && !gameOver) {
                board[row][col] = symbol;
                System.out.println(board[row][col]);
                printBoard();
                return true;
            }
            return false;
        } finally {
            lock.unlock();
        }
    }

    public boolean checkGameOver() {
        lock.lock();
        try {
            return checkWinner() || checkDraw();
        } finally {
            lock.unlock();
        }
    }

    public boolean checkWinner() {
        lock.lock();
        try {
            for (int i = 0; i < 3; i++) {
                if (board[i][0] == board[i][1] && board[i][1] == board[i][2] && board[i][0] != '-') {
                    gameOver = true;
                    return true;
                }
                if (board[0][i] == board[1][i] && board[1][i] == board[2][i] && board[0][i] != '-') {
                    gameOver = true;
                    return true;
                }
            }
            if (board[0][0] == board[1][1] && board[1][1] == board[2][2] && board[0][0] != '-') {
                gameOver = true;
                return true;
            }
            if (board[0][2] == board[1][1] && board[1][1] == board[2][0] && board[0][2] != '-') {
                gameOver = true;
                return true;
            }
            return false;
        } finally {
            lock.unlock();
        }
    }

    public boolean checkDraw() {
        lock.lock();
        try {
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    if (board[i][j] == '-') {
                        return false;
                    }
                }
            }
            gameOver = true;
            return true;
        } finally {
            lock.unlock();
        }
    }

    public boolean isGameOver() {
        lock.lock();
        try {
            return gameOver;
        } finally {
            lock.unlock();
        }
    }
}
