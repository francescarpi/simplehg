# SimpleHG

SimpleHG es un sencillo plugin de Emacs para gestionar tareas simples de mercurial.

## Instalación

* Clonar el repositorio en tu carpeta de plugins de emacs.

<pre>
	git clone ...
</pre>

* Editar tu fichero de configuración de emacs **.emacs**.

<pre>
(require 'simplehg)
(global-set-key (kbd "M-n") 'simplehg-status-buffer)
</pre>

Se ha asignado la combinación de teclas **M-n** para iniciar la ventana de estado. Pero puede añadir la que más te convenga.

Si emacs no encuentra el paquete **simplehg**, asegúrate de que esté incluido en el __load-pagh__.

<pre>
(add-to-list 'load-path "<your-pagh>/simplehg")
</pre>


