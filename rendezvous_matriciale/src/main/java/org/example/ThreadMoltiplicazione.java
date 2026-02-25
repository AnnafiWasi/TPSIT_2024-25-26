package org.example;

import java.util.concurrent.Semaphore;

public class ThreadMoltiplicazione extends Thread{

    private int[][] matrice1;
    private int[][] matrice2;
    private int[][] result;
    private Semaphore semaforo;

    public ThreadMoltiplicazione(int[][] matrice1, int[][] matrice2, int result[][], Semaphore semaforo) {
        this.matrice1 = matrice1;
        this.matrice2 = matrice2;
        this.result = result;
        this.semaforo = semaforo;
    }

    public void run(){
        try{
            semaforo.acquire(1);
            for (int i = 0; i < result.length; i++){
                for (int j = 0; j < result.length; j++){
                    result[i][j] = matrice1[i][j] * matrice2[i][j];
                }
            }
            semaforo.release();
        }catch(InterruptedException e){
            e.printStackTrace();
        }


    }
}