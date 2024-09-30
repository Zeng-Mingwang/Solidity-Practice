// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract TodoList {
    struct Task {
        string name;
        bool completed;
        uint createAt;
    }

    mapping (uint => Task) public tasks;
    uint public taskCount;

    event TaskCreated(uint id, string name, uint createdAt);
    event TaskNameUpdated(uint id, string newName);
    event TaskStatusToggled(uint id, bool completed);

    function createTask(string memory _name) public {
        taskCount++;
        tasks[taskCount] = Task(_name, false, block.timestamp);
        emit TaskCreated(taskCount, _name, block.timestamp);
    }

    function modifyTask(uint id, string memory _newName) public {
        require(id >0 && id <= taskCount, "Not Found Task");
        tasks[id].name = _newName;
        emit TaskNameUpdated(id, _newName);
        
    }

    function toggleTaskStatus(uint id) public {
        require(id >0 && id <= taskCount, "Not Found Task");
        tasks[id].completed = !tasks[id].completed;
        
        emit TaskStatusToggled(id, !tasks[id].completed);
    }

    function setTaskStatus(uint id, bool status) public {
         require(id >0 && id <= taskCount, "Not Found Task");
         tasks[id].completed = status;
         emit TaskStatusToggled(id, status);
    }

    function getTask(uint id) public view returns (string memory name, bool completed, uint createdAt){
        require(id >0 && id <= taskCount,"Not Found Task");
        Task memory task = tasks[id];
        return (task.name, task.completed, task.createAt);
    }
}