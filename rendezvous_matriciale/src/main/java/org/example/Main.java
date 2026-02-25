package org.example;

import java.util.Random;
import java.util.Scanner;
import java.util.concurrent.Semaphore;

public class Main {
    public static void main(String[] args) {
        Scanner kbd = new Scanner(System.in);
        System.out.println("La lunghezza della matrice: ");
        int n = kbd.nextInt();
        int[][] matrice1 = new int[n][n];
        int[][] matrice2 = new int[n][n];
        int[][] result = new int[n][n];
        Random rnd = new Random();
        System.out.print("Matrice 1: ");
        for (int i = 0; i < matrice1.length; i++){
            for (int j = 0; j < matrice1.length; j++){
                matrice1[i][j] = rnd.nextInt(1,5);
                System.out.print(matrice1[i][j] + " ");
            }
        }
        System.out.print("\nMatrice 2: ");
        for (int i = 0; i < matrice2.length; i++){
            for (int j = 0; j < matrice2.length; j++){
                matrice2[i][j] = rnd.nextInt(1,5);
                System.out.print(matrice2[i][j] + " ");
            }
        }

        Semaphore semaforo = new Semaphore(1);
        Thread threads[][] = new Thread[n][n];

        for (int i = 0; i < threads.length; i++){
            for (int j = 0; j < threads.length; j++){
                threads[i][j] = new ThreadMoltiplicazione(matrice1, matrice2, result, semaforo);
                threads[i][j].start();
            }
        }

        Thread somma = new ThreadSomma(result);
        somma.start();

        System.out.print("\nRisultato: ");
        for (int i = 0; i < result.length; i++){
            for (int j = 0; j < result.length; j++){
                System.out.print(result[i][j] + " ");
            }
        }
    }
}