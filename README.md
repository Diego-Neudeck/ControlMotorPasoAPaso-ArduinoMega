# ControlMotorPasoAPaso-ArduinoMega
Se realiza un control de marcha, parada y sentido de giro de un motor paso a paso

![image](https://user-images.githubusercontent.com/64299278/81080480-221a3380-8ec7-11ea-80be-cf7eeaa88ded.png)
## Se mostrara el esquema del circuito del motor paso a paso.

![image](https://user-images.githubusercontent.com/64299278/81080570-40802f00-8ec7-11ea-82df-1ec512c9cb29.png)

Para esta actividad se tenía un motor paso a paso, que es un actuador que gira su eje de acuerdo a la secuencia de encendido de sus bobinas. La rotación del eje puede efectuarse en ambos sentidos, utilizando tanto la secuencia de paso completo como de medio paso. Para movimientos de precisión se utiliza el medio paso, ya que la resolución en la rotación es mejor que el paso completo (posee menor relación ángulo/paso). 
Con estos conceptos se pasó a realizar un programa en Assembler que permite controlar un motor PAP unipolar de la siguiente forma:
•	Cuando se energiza el motor, este permanece apagado.
•	Al pulsar la llave P1, el motor pasa de apagado a prendido o viceversa (dependiendo cual es el estado anterior).
•	La llave S1 controla el sentido de giro del motor, el cual puede ser horario o antihorario.
•	La llave S2 controla la secuencia de giro del motor, la cual puede ser de paso completo o medio paso.
•	Si el usuario altera el estado de las llaves S1 y S2 para modificar el paso y/o el sentido de giro cuando el motor está en marcha, no hay efecto alguno en el motor. El cambio surge efecto en el motor luego de apagar y volver a encender (mediante P1) el mismo.
Ítem 1:
Para iniciar se determinó la secuencia para que el motor PAP suministrada por la catedra gire en modo completo y modo medio paso, en sentido horario y antihorario. Donde se pasó a realizar la siguiente tabla para el motor PM42S-048.
## Horario y paso completo.
# 0 0	0	1
# 0	0	1	0
# 0	1	0	0
# 1	0	0	0
 Antihorario y paso completo.
# 1	0	0	0
# 0	1	0	0
# 0	0	1	0
# 0	0	0	1
 Horario medio paso.
# 0	0	0	1
# 0	0	1	1
# 0	0	1	0
# 0	1	1	0
# 0	1	0	0
# 1	1	0	0
# 1	0	0	0
# 1	0	0	1

 Antihorario medio paso.
# 1	0	0	0
# 1	1	0	0
# 0	1	0	0
# 0	1	1	0
# 0	0	1	0
# 0	0	1	1
# 0	0	0	1
# 1	0	0	1

Ítem 2:
Luego de determinar las secuencias del motor, se pasó a realizar un diagrama de flujo para el programa a realizar.
Donde el programa principal tiene la siguiente estructura, en la cual se definen variables, se configuran los puertos de entrada y salida y el timer 1 para hacer girar el motor PAP.

![image](https://user-images.githubusercontent.com/64299278/81359454-8f88b880-90af-11ea-8855-8f39f9003988.png)

Se muestra una imagen de la prueba que se hizo en el arduino mega
![image](https://user-images.githubusercontent.com/64299278/81359540-cced4600-90af-11ea-892b-e31477e1d4e8.png)
