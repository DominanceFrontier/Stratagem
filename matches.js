# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

function GameView(canvas, width, height){
  this.canvas = canvas;
  this.canvas.width = width;
  this.canvas.height = height;
  this.context = this.canvas.getContext("2d");
  this.elements = [];
}

GameView.prototype.display = function(){
  for (element in this.elements){
    element.draw(this.context);
  }
}

GameView.prototype.registerElement = function(element){
  this.elements.push(element);
}

GameView.prototype.removeElement = function(element){
  index = this.elements.indexOf(element);
  if (index > -1)
    this.elements.slice(index, 1);
}

function BoardView(state){
  this.state = JSON.parse(state);
}

BoardView.prototype.update = function(state){
  this.state = JSON.parse(state);
}

BoardView.prototype.draw = function(context){
}

tttView = new GameView(document.getElementById('gameBoard'), 500, 500);
tttBoardView = new BoardView("[[" "," "," "],[" "," "," "],[" "," "," "]]");
tttBoardView.draw = function(context){
  function drawX(){
  }
  function drawO(){
  }
}

tttView.registerElement(tttBoard);

window.onload = function() {
}


