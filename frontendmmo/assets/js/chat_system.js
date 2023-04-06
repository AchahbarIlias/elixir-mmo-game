let chatsystem = {
  init(socket) {
    let channel = socket.channel("global_chat:lobby", {})
    channel.join()
    this.listenForChats(channel)
  },

  listenForChats(channel) {
    document.getElementById("chat-form").addEventListener('submit', function (e) {
      e.preventDefault();
      let message = document.getElementById("user-msg").value;
      let name = document.getElementById("username").innerText;

      channel.push("shout", { name: name, message: message });

      document.getElementById("user-msg").value = "";
    })

    channel.on("shout", payload => {
      let chatbox = document.getElementById("chat-box");
      let messageblock = document.createElement("div");
      console.log(payload);
      messageblock.insertAdjacentHTML("afterbegin", `<p>${payload.name}: ${payload.message}</p>`);
      chatbox.appendChild(messageblock);
    }
    )
  }
}

export default chatsystem;