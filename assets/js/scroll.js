export default ScrollDown = {
  mounted() {
    let messageListContainer = document.getElementById("messages")      
    window.addEventListener("phx:scrollToBottom", (e) => {
      console.log(e)
      messageListContainer.scrollTop = messageListContainer.scrollHeight
    })
  },
}
  