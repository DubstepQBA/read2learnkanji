import React, { useState, useEffect, useRef } from 'react';
import Word from './Components/Word';
import './App.css';
import axios from 'axios';

const MemoizedWord = React.memo(Word);

function App() {
  const [wordData, setWordData] = useState([]);
  const [pageSizeCharacter, setPageSizeCharacter] = useState(1000);
  const [currentPage, setCurrentPage] = useState(0);
  const [totalLength, setTotalLength] = useState(0);
  const [file, setFile] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const controllerRef = useRef(null);
  const [prefetchedData, setPrefetchedData] = useState({});
  const [selectedBook, setSelectedBook] = useState(null); // New state for pre-selected books
  const [imageFile, setImageFile] = useState(null);
  const fileName = file ? file.name : selectedBook;
  const fileInputRef = useRef(null);
  const imageInputRef = useRef(null);


   useEffect(() => {
  if (file || imageFile || selectedBook) {
    handleSubmit();
  }
  // eslint-disable-next-line
}, [file, imageFile, selectedBook, currentPage]);


  const handleFileChange = (event) => {
    // Reset selected book when a file is uploaded
    setSelectedBook(null);
    setImageFile(null);
    setFile(event.target.files[0]);
    setCurrentPage(0);
    setPrefetchedData({});
  };

  const handleImageFileChange = (event) => {
    // Reset other file states
    setFile(null);
    setSelectedBook(null);

    const uploadedFile = event.target.files[0];
    setImageFile(uploadedFile);
    setCurrentPage(0);
    setPrefetchedData({});
  };

    const handleSubmit = () => {
    if (file || imageFile || selectedBook) {
      fetchAPI(currentPage, (data) => {
        setWordData(data.data);
        setTotalLength(data.totalLength);
      });
    }
  };

  const handleBookSelect = (bookName) => {
    // Reset uploaded file when a pre-selected book is chosen
    setFile(null);
    setImageFile(null);
    setSelectedBook(bookName);
    setCurrentPage(0);
    setPrefetchedData({});
  };

  const handleCancel = () => {
    if (controllerRef.current) {
      controllerRef.current.abort();
      setIsLoading(false);
      console.log("Request cancelled.");
    }
  };

  const handleReset = () => {
    if (controllerRef.current) {
      controllerRef.current.abort();
    }
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
    if (imageInputRef.current) {
      imageInputRef.current.value = "";
    }
    setWordData([]);
    setCurrentPage(0);
    setTotalLength(0);
    setFile(null);
    setImageFile(null);
    setSelectedBook(null); // Reset selected book
    setIsLoading(false);
    setPrefetchedData({});
  };

  async function fetchAPI(pageNumber, onSuccess) {
    setIsLoading(true);
    controllerRef.current = new AbortController();
    const signal = controllerRef.current.signal;
    
    let response;
    try {
      let formData = new FormData();
      let endpoint = '';
      
      if (imageFile) {
        endpoint = '/ocr';
        formData.append('image_file', imageFile);
      } else if (file) {
        endpoint = '/analyze';
        formData.append('file', file);
      } else if (selectedBook) {
        // Book requests are a special case, they don't use FormData.
        response = await axios.post('http://127.0.0.1:8080/analyze', {
          filepath: selectedBook,
          start_position: pageNumber * pageSizeCharacter,
          page_size: pageSizeCharacter,
        }, {
          signal: signal,
        });
        onSuccess(response.data);
        setIsLoading(false);
        return;
      } else {
        setIsLoading(false);
        return;
      }

      // Add pagination data to the FormData for file/image uploads
      formData.append('start_position', pageNumber * pageSizeCharacter);
      formData.append('page_size', pageSizeCharacter);

      response = await axios.post(`http://127.0.0.1:8080${endpoint}`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
        signal: signal,
      });

      onSuccess(response.data);
      console.log("API response:", response.data);
      setIsLoading(false);

    } catch (error) {
      if (axios.isCancel(error)) {
        console.log('Request aborted by user');
      } else {
        console.error("Error fetching data:", error);
      }
      setIsLoading(false);
    }
  }

   function handleSwipe(id) {
  setWordData(prev =>
    prev.map(paragraph =>
      paragraph.map(word => {
        if (word.id !== id) return word; // leave others untouched

        // Here you have the clicked word object
        if (word.showFurigana && word.showTranslation) {
          return { ...word, showFurigana: false, showTranslation: false };
        } else if (!word.showFurigana && word.showTranslation) {
          return { ...word, showFurigana: true };
        } else if (word.showFurigana && !word.showTranslation) {
          return { ...word, showTranslation: true };
        } else {
          return { ...word, showFurigana: true };
        }
      })
    )
  );
}

  const handleNextPage = () => {
    if ((currentPage + 1) * pageSizeCharacter < totalLength) {
      setCurrentPage(prevPage => prevPage + 1);
    }
  };

  const handlePrevPage = () => {
    setCurrentPage(prevPage => Math.max(0, prevPage - 1));
  };
console.log("receive data:", wordData);
// Generate paragraph elements
  const paragraphElement = wordData.map((show, i) => (
    <p key={i}>
      {show.map((item, j) => (
        <MemoizedWord
          key={item.id ?? `text-${i}-${j}`}
          handleSwipe={handleSwipe}
          furigana={item.furigana}
          translation={item.translation}
          kanji={item.kanji}
          showFurigana={item.showFurigana}
          showTranslation={item.showTranslation}
          type={item.type}
          id={item.id}
          value={item.value}
        />
      ))}
    </p>
  ));

  return (
    <>
      <h1>Japanese Text Reader</h1>
      
      {/* File Upload Section */}
      <div className="file-upload">
        <label htmlFor="file-input">
          <button onClick={() => document.getElementById('file-input').click()}>Upload Document</button>
        </label>
        <input type="file" onChange={handleFileChange} id="file-input" ref={fileInputRef} style={{ display: 'none' }} accept=".pdf,.doc,.docx,.txt"/>
        <p className="file-name">{file ? file.name : 'No document selected'}</p>
      </div>

      {/* Picture Upload Section */}
      <div className="image-upload">
        <label htmlFor="image-input">
          <button onClick={() => document.getElementById('image-input').click()}>Upload Image</button>
        </label>
        <input type="file" onChange={handleImageFileChange} id="image-input" ref={imageInputRef} style={{ display: 'none' }} accept=".jpg,.jpeg,.png"/>
        <p className="file-name">{imageFile ? imageFile.name : 'No image file selected'}</p>
      </div>

      {/*submit, reset and cancel buttons */}
      <div className="control-buttons">
          <button onClick={handleSubmit} disabled={!file && !imageFile && !selectedBook}>Submit</button>
          {isLoading && <button onClick={handleCancel}>Cancel</button>}
          <button onClick={handleReset}>Reset</button>
      </div>    

      {/* Pre-selected Books Section */}
      <div className="pre-selected-books">
        <p>Or choose a pre-selected book:</p>
        <button onClick={() => handleBookSelect('wagahaiwa_nekodearu.txt')}>Wagahai Wa Neko De Aru (dificult)</button>
        <button onClick={() => handleBookSelect('momotaro.txt')}>momotaro (easy)</button>
        <button onClick={() => handleBookSelect('Book3.txt')}>Book 3</button>
      </div>

      {/* navigation buttons */}
      <div className="page-navigation">
        <button onClick={handlePrevPage} disabled={currentPage === 0}>Previous Page</button>
        <span>Page {currentPage + 1}</span>
        <button onClick={handleNextPage} disabled={(currentPage + 1) * pageSizeCharacter >= totalLength}>Next Page</button>
      </div>

      <div className="main_text" style={{ lineHeight: 1.8 }}>
        {isLoading && !prefetchedData[`page_${currentPage}`] ? (
          <p>Loading...</p>
        ) : (
          <>
            <div className="jisage_8" style={{ marginLeft: '8em' }}>
              <h4 className="naka-midashi">
                <a className="midashi_anchor" id="midashi10">一</a>
              </h4>
            </div>
            {paragraphElement}
          </>
        )}
      </div>
    </>
  );
}

export default App;