/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package tris;

import java.util.Random;

/**
 *
 * @author annafi.kazi
 */
public class Player extends Thread {
    private final Board board;
    private final char symbol;
    private final Random random = new Random();

    public Player(Board board, char symbol) {
        this.board = board;
        this.symbol = symbol;
    }

    @Override
    public void run() {
        while (!board.isGameOver()) {
            try {
                Thread.sleep(500 + random.nextInt(1000));
                makeRandomMove();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
    
    private void makeRandomMove() {
        int row, col;
        do {
            row = random.nextInt(3);
            col = random.nextInt(3);
        } while (!board.makeMove(row, col, symbol));
        
        if (board.checkGameOver()) {
            System.out.println("Gioco finito! Il vincitore e' " + symbol);
        }
    }
}
