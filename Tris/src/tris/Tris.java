/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package tris;

/**
 *
 * @author annafi.kazi
 */
public class Tris {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Board board = new Board();
        
        Player player1 = new Player(board, 'X');
        Player player2 = new Player(board, 'O');

        player1.start();
        player2.start();

        try {
            player1.join();
            player2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        System.out.println("Partita terminata.");
    }
}
