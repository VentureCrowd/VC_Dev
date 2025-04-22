/*
All the document scripts here.
*/


    var prevScrollpos = window.pageYOffset;
    
    window.onscroll = function () {
        
        if (window.pageYOffset > 100) {
           
            var currentScrollPos = window.pageYOffset;
            var pageX = document.querySelector('.navigation.cVC_CF_StandardFrontEndPageTheme');
            var pageY = document.querySelector('.navigation.cVentureCrowdThemeLayoutTest');
            var pageZ = document.querySelector('.navigation.cForgotPasswordTheme');
            var pageNoFooter = document.querySelector('.navigation.cVC_CF_StandardFrontEndPageTheme_noFooter');

            if(pageX != null){
                if (prevScrollpos > currentScrollPos) {
                    pageX.style.top = "0";
                } else {
                    pageX.style.top = "-100px";
                }    
            }
            
            if(pageY != null){
                if (prevScrollpos > currentScrollPos) {
                    pageY.style.top = "0";
                } else {
                    pageY.style.top = "-100px";
                }    
            }
            
            if(pageZ != null){
                if (prevScrollpos > currentScrollPos) {
                    pageZ.style.top = "0";
                } else {
                    pageZ.style.top = "-100px";
                }    
            }
            
            if(pageNoFooter != null){
                if (prevScrollpos > currentScrollPos) {
                    pageNoFooter.style.top = "0";
                } else {
                    pageNoFooter.style.top = "-100px";
                }    
            }

            prevScrollpos = currentScrollPos;
        } else {
            if(pageX != null){
            pageX.style.top = "0";
            }
            if(pageY != null){
            pageY.style.top = "0";
            }
            if(pageZ != null){
                pageZ.style.top = "0";
            }
            if(pageNoFooter != null){
                pageNoFooter.style.top = "0";
            }
        }

    }

